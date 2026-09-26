import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

let env: RulesTestEnvironment;

const owner = { uid: 'owner1' };
const other = { uid: 'owner2' };
const doctorId = 'doc1';

const as = (uid: string, claims: Record<string, unknown> = {}) =>
  env.authenticatedContext(uid, claims).firestore();
const asDoctor = (uid = doctorId) => as(uid, { role: 'doctor' });
const asAdmin = () => as('admin1', { role: 'admin' });

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-petcare-rules',
    firestore: { rules: readFileSync(resolve(__dirname, '../../../firestore.rules'), 'utf8') },
  });
});

afterAll(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/owner1'), { fullName: 'Kasun', email: 'k@pets.lk' });
    await setDoc(doc(db, 'users/owner1/pets/bruno'), { ownerId: 'owner1', name: 'Bruno', species: 'dog' });
    await setDoc(doc(db, 'users/owner1/pets/milo'), { ownerId: 'owner1', name: 'Milo', species: 'cat' });
    await setDoc(doc(db, 'users/owner1/vaccinations/v1'), { ownerId: 'owner1', petId: 'bruno', vaccineName: 'Rabies' });
    await setDoc(doc(db, 'users/owner1/vaccinations/v2'), { ownerId: 'owner1', petId: 'milo', vaccineName: 'FVRCP' });
    await setDoc(doc(db, 'doctors/doc1'), { uid: 'doc1', fullName: 'Dr. Nimali', status: 'approved', doctorCode: 'DR-ABC123' });
    await setDoc(doc(db, 'doctors/doc2'), { uid: 'doc2', fullName: 'Dr. Pending', status: 'pending' });
    // Bruno (not Milo) is shared with doc1.
    await setDoc(doc(db, 'shares/owner1_bruno_doc1'), {
      ownerId: 'owner1', petId: 'bruno', doctorId: 'doc1', petName: 'Bruno',
    });
  });
});

describe('owners', () => {
  it('manage their own data only', async () => {
    await assertSucceeds(getDoc(doc(as(owner.uid), 'users/owner1/pets/bruno')));
    await assertSucceeds(setDoc(doc(as(owner.uid), 'users/owner1/pets/kiwi'), { ownerId: 'owner1', name: 'Kiwi' }));
    await assertFails(getDoc(doc(as(other.uid), 'users/owner1/pets/bruno')));
    await assertFails(getDocs(collection(as(other.uid), 'users/owner1/vaccinations')));
  });
});

describe('doctors', () => {
  it('read a shared pet and its records, filtered by pet', async () => {
    const db = asDoctor();
    await assertSucceeds(getDoc(doc(db, 'users/owner1/pets/bruno')));
    await assertSucceeds(getDoc(doc(db, 'users/owner1/vaccinations/v1')));
    await assertSucceeds(
      getDocs(query(collection(db, 'users/owner1/vaccinations'), where('petId', '==', 'bruno'))),
    );
  });

  it('cannot see pets that were not shared with them', async () => {
    const db = asDoctor();
    await assertFails(getDoc(doc(db, 'users/owner1/pets/milo')));
    await assertFails(getDoc(doc(db, 'users/owner1/vaccinations/v2')));
    await assertFails(getDocs(query(collection(db, 'users/owner1/vaccinations'), where('petId', '==', 'milo'))));
    // An unfiltered query could include other pets' records.
    await assertFails(getDocs(collection(db, 'users/owner1/vaccinations')));
    await assertFails(getDoc(doc(db, 'users/owner1')));
  });

  it('need the doctor role, not just a share', async () => {
    await assertFails(getDoc(doc(as(doctorId), 'users/owner1/pets/bruno')));
  });

  it('add records but never delete, and only edit their own', async () => {
    const db = asDoctor();
    const record = { ownerId: 'owner1', petId: 'bruno', vaccineName: 'DHPP', addedByUid: doctorId };
    await assertSucceeds(setDoc(doc(db, 'users/owner1/vaccinations/d1'), record));
    await assertSucceeds(updateDoc(doc(db, 'users/owner1/vaccinations/d1'), { notes: 'Batch 42' }));
    await assertFails(deleteDoc(doc(db, 'users/owner1/vaccinations/d1')));
    await assertFails(updateDoc(doc(db, 'users/owner1/vaccinations/v1'), { notes: 'changed' }));
    await assertFails(deleteDoc(doc(db, 'users/owner1/vaccinations/v1')));
    // Not for an unshared pet, not pretending to be someone else, not other collections.
    await assertFails(setDoc(doc(db, 'users/owner1/vaccinations/d2'), { ...record, petId: 'milo' }));
    await assertFails(setDoc(doc(db, 'users/owner1/vaccinations/d3'), { ...record, addedByUid: 'owner1' }));
    await assertFails(setDoc(doc(db, 'users/owner1/pets/bruno'), { name: 'Hacked' }));
    await assertFails(setDoc(doc(db, 'users/owner1/weights/w1'), { ...record }));
  });

  it('lose access as soon as the share is revoked', async () => {
    await assertSucceeds(deleteDoc(doc(as(owner.uid), 'shares/owner1_bruno_doc1')));
    await assertFails(getDoc(doc(asDoctor(), 'users/owner1/pets/bruno')));
  });
});

describe('doctor applications', () => {
  it('can only be created as pending, without a code', async () => {
    const db = as('newdoc');
    await assertFails(setDoc(doc(db, 'doctors/newdoc'), { uid: 'newdoc', status: 'approved' }));
    await assertFails(setDoc(doc(db, 'doctors/newdoc'), { uid: 'newdoc', status: 'pending', doctorCode: 'DR-X' }));
    await assertFails(setDoc(doc(db, 'doctors/someoneelse'), { uid: 'someoneelse', status: 'pending' }));
    await assertSucceeds(setDoc(doc(db, 'doctors/newdoc'), { uid: 'newdoc', fullName: 'Dr. New', status: 'pending' }));
  });

  it('let doctors edit their profile but not their status or code', async () => {
    const db = as('doc2');
    await assertSucceeds(updateDoc(doc(db, 'doctors/doc2'), { clinicName: 'Happy Paws' }));
    await assertFails(updateDoc(doc(db, 'doctors/doc2'), { status: 'approved' }));
    await assertFails(updateDoc(doc(db, 'doctors/doc2'), { doctorCode: 'DR-FAKE01' }));
  });

  it('are findable by code only once approved', async () => {
    const db = as(owner.uid);
    await assertSucceeds(
      getDocs(query(collection(db, 'doctors'), where('doctorCode', '==', 'DR-ABC123'), where('status', '==', 'approved'))),
    );
    await assertFails(getDocs(query(collection(db, 'doctors'), where('doctorCode', '==', 'DR-ABC123'))));
    await assertFails(getDoc(doc(db, 'doctors/doc2')));
  });
});

describe('shares', () => {
  const share = (petId: string, doc: string) => ({ ownerId: 'owner1', petId, doctorId: doc, petName: 'Milo' });

  it('owners share their own pets with approved doctors', async () => {
    const db = as(owner.uid);
    await assertSucceeds(setDoc(doc(db, 'shares/owner1_milo_doc1'), share('milo', 'doc1')));
    await assertFails(setDoc(doc(db, 'shares/owner1_milo_doc2'), share('milo', 'doc2'))); // pending doctor
    await assertFails(setDoc(doc(db, 'shares/owner1_ghost_doc1'), share('ghost', 'doc1'))); // no such pet
    await assertFails(setDoc(doc(db, 'shares/wrong-id'), share('milo', 'doc1')));
    await assertFails(
      setDoc(doc(as(other.uid), 'shares/owner1_milo_doc1'), share('milo', 'doc1')), // not their pet
    );
  });

  it('are visible to the owner and the doctor only', async () => {
    await assertSucceeds(getDocs(query(collection(as(owner.uid), 'shares'), where('ownerId', '==', 'owner1'))));
    await assertSucceeds(getDocs(query(collection(asDoctor(), 'shares'), where('doctorId', '==', doctorId))));
    await assertFails(getDocs(query(collection(as(other.uid), 'shares'), where('ownerId', '==', 'owner1'))));
  });
});

describe('admins', () => {
  it('read profiles and doctors but not pet records', async () => {
    const db = asAdmin();
    await assertSucceeds(getDoc(doc(db, 'users/owner1')));
    await assertSucceeds(getDocs(collection(db, 'doctors')));
    await assertFails(getDoc(doc(db, 'users/owner1/pets/bruno')));
    await assertFails(getDocs(collection(db, 'users/owner1/vaccinations')));
  });
});
