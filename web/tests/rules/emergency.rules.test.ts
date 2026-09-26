import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { assertFails, assertSucceeds, initializeTestEnvironment, type RulesTestEnvironment } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc } from 'firebase/firestore';
import { afterAll, beforeAll, describe, it } from 'vitest';

// The mobile app's emergency profile / QR ID flow (see EmergencyProfileRepositoryImpl).
let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-petcare-rules-emergency',
    firestore: { rules: readFileSync(resolve(__dirname, '../../../firestore.rules'), 'utf8') },
  });
});
afterAll(() => env.cleanup());

describe('emergency profiles', () => {
  it('the owner can check an id, save settings, publish, update and unpublish', async () => {
    const db = env.authenticatedContext('owner1').firestore();
    await assertSucceeds(getDoc(doc(db, 'publicProfiles/PC-ABC2345'))); // uniqueness check
    await assertSucceeds(
      setDoc(doc(db, 'users/owner1/emergencyProfiles/bruno'), {
        petId: 'bruno', ownerId: 'owner1', publicId: 'PC-ABC2345', enabled: true, updatedAt: serverTimestamp(),
      }),
    );
    const page = { publicId: 'PC-ABC2345', ownerId: 'owner1', petName: 'Bruno', species: 'dog', contactPhone: '0771234567' };
    await assertSucceeds(setDoc(doc(db, 'publicProfiles/PC-ABC2345'), { ...page, updatedAt: serverTimestamp() }));
    await assertSucceeds(setDoc(doc(db, 'publicProfiles/PC-ABC2345'), { ...page, petName: 'Bruno B', updatedAt: serverTimestamp() }));
    await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), 'publicProfiles/PC-ABC2345')));
    await assertFails(setDoc(doc(env.authenticatedContext('eve').firestore(), 'publicProfiles/PC-ABC2345'), { ...page, ownerId: 'eve' }));
    await assertSucceeds(deleteDoc(doc(db, 'publicProfiles/PC-ABC2345')));
  });
});
