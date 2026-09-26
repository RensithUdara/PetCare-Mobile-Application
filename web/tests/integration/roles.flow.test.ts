/**
 * End-to-end role flow against the Auth, Firestore and Functions emulators:
 * owner, doctor application, admin approval, sharing, doctor records.
 *
 * Run from the repo root: `npm --prefix web run test:e2e`.
 */
import { deleteApp, initializeApp, type FirebaseApp } from 'firebase/app';
import {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  getAuth,
  GoogleAuthProvider,
  signInWithCredential,
  type Auth,
} from 'firebase/auth';
import {
  addDoc,
  collection,
  connectFirestoreEmulator,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  getFirestore,
  query,
  setDoc,
  where,
  type Firestore,
} from 'firebase/firestore';
import { connectFunctionsEmulator, getFunctions, httpsCallable, type Functions } from 'firebase/functions';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

const PROJECT = 'demo-petcare';
const apps: FirebaseApp[] = [];

interface Client {
  auth: Auth;
  db: Firestore;
  fn: Functions;
  call: <T = unknown>(name: string, data?: unknown) => Promise<T>;
}

function client(name: string): Client {
  const app = initializeApp({ apiKey: 'demo-key', projectId: PROJECT, authDomain: `${PROJECT}.firebaseapp.com` }, name);
  apps.push(app);
  const auth = getAuth(app);
  connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
  const db = getFirestore(app);
  connectFirestoreEmulator(db, '127.0.0.1', 8085);
  const fn = getFunctions(app);
  connectFunctionsEmulator(fn, '127.0.0.1', 5001);
  return { auth, db, fn, call: async (n, data) => (await httpsCallable(fn, n)(data)).data as never };
}

const role = async (c: Client) => (await c.auth.currentUser!.getIdTokenResult(true)).claims.role ?? 'owner';

let owner: Client;
let vet: Client;
let admin: Client;
let stranger: Client;
let ownerId: string;
let vetId: string;

beforeAll(async () => {
  // Fresh emulator state.
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJECT}/accounts`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:8085/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: 'DELETE' });

  owner = client('owner');
  vet = client('vet');
  admin = client('admin');
  stranger = client('stranger');
  ownerId = (await createUserWithEmailAndPassword(owner.auth, 'kasun@pets.lk', 'secret123')).user.uid;
  vetId = (await createUserWithEmailAndPassword(vet.auth, 'nimali@vet.lk', 'secret123')).user.uid;
  await createUserWithEmailAndPassword(stranger.auth, 'eve@x.lk', 'secret123');
  // The emulator accepts unsigned Google tokens; this one has a verified email
  // listed in ADMIN_EMAILS (functions/.env.local).
  await signInWithCredential(
    admin.auth,
    GoogleAuthProvider.credential(JSON.stringify({ sub: 'admin-1', email: 'admin@petcare.test', email_verified: true })),
  );
}, 60_000);

afterAll(async () => {
  await Promise.all(apps.map((a) => deleteApp(a)));
});

describe('roles', () => {
  it('only listed, verified emails can claim admin', async () => {
    await expect(stranger.call('bootstrapAdmin')).rejects.toThrow(/not on the admin list/);
    await admin.call('bootstrapAdmin');
    expect(await role(admin)).toBe('admin');
  });

  it('non-admins cannot use admin functions', async () => {
    await expect(owner.call('adminStats')).rejects.toThrow(/Admins only/);
    await expect(owner.call('setUserRole', { uid: ownerId, role: 'admin' })).rejects.toThrow(/Admins only/);
  });

  it('a doctor applies, is approved by the admin and gets a code', async () => {
    await setDoc(doc(vet.db, 'doctors', vetId), {
      uid: vetId,
      fullName: 'Dr. Nimali Perera',
      email: 'nimali@vet.lk',
      clinicName: 'Happy Paws',
      licenseNumber: 'SLVC-1234',
      status: 'pending',
    });
    expect(await role(vet)).toBe('owner');

    // Doctors cannot approve themselves.
    await expect(setDoc(doc(vet.db, 'doctors', vetId), { status: 'approved' }, { merge: true })).rejects.toThrow();

    const res = await admin.call<{ status: string; doctorCode: string }>('reviewDoctor', { uid: vetId, approve: true });
    expect(res.status).toBe('approved');
    expect(res.doctorCode).toMatch(/^DR-[A-HJ-NP-Z2-9]{6}$/);
    expect(await role(vet)).toBe('doctor');
    const application = await getDoc(doc(vet.db, 'doctors', vetId));
    expect(application.get('doctorCode')).toBe(res.doctorCode);
  });

  it('admins see users with roles and platform stats', async () => {
    const { users } = await admin.call<{ users: { email: string; role: string }[] }>('listUsers', {});
    expect(users.find((u) => u.email === 'nimali@vet.lk')?.role).toBe('doctor');
    expect(users.find((u) => u.email === 'admin@petcare.test')?.role).toBe('admin');
    const stats = await admin.call<{ doctors: { approved: number } }>('adminStats');
    expect(stats.doctors.approved).toBe(1);
  });
});

describe('sharing', () => {
  let petId: string;
  let code: string;

  it('the owner finds the vet by code and shares a pet', async () => {
    petId = (await addDoc(collection(owner.db, 'users', ownerId, 'pets'), { ownerId, name: 'Bruno', species: 'dog', gender: 'male' })).id;
    await addDoc(collection(owner.db, 'users', ownerId, 'vaccinations'), { ownerId, petId, vaccineName: 'Rabies', category: 'core' });

    code = (await getDoc(doc(vet.db, 'doctors', vetId))).get('doctorCode');
    const found = await getDocs(
      query(collection(owner.db, 'doctors'), where('doctorCode', '==', code), where('status', '==', 'approved')),
    );
    expect(found.docs.map((d) => d.id)).toEqual([vetId]);

    await setDoc(doc(owner.db, 'shares', `${ownerId}_${petId}_${vetId}`), {
      ownerId,
      petId,
      doctorId: vetId,
      petName: 'Bruno',
      doctorName: 'Dr. Nimali Perera',
      ownerName: 'Kasun',
    });
  });

  it('the vet sees the patient and its records, and adds a vaccination', async () => {
    const patients = await getDocs(query(collection(vet.db, 'shares'), where('doctorId', '==', vetId)));
    expect(patients.docs.map((d) => d.get('petName'))).toEqual(['Bruno']);

    expect((await getDoc(doc(vet.db, 'users', ownerId, 'pets', petId))).get('name')).toBe('Bruno');
    const records = await getDocs(query(collection(vet.db, 'users', ownerId, 'vaccinations'), where('petId', '==', petId)));
    expect(records.docs.map((d) => d.get('vaccineName'))).toEqual(['Rabies']);

    const added = await addDoc(collection(vet.db, 'users', ownerId, 'vaccinations'), {
      ownerId,
      petId,
      vaccineName: 'DHPP',
      category: 'core',
      addedByUid: vetId,
      addedByName: 'Dr. Nimali Perera',
    });
    await expect(deleteDoc(added)).rejects.toThrow(); // vets never delete

    // The owner sees the vet's record in their own data.
    const mine = await getDocs(query(collection(owner.db, 'users', ownerId, 'vaccinations'), where('petId', '==', petId)));
    expect(mine.docs.map((d) => d.get('vaccineName')).sort()).toEqual(['DHPP', 'Rabies']);
  });

  it('strangers see nothing', async () => {
    await expect(getDoc(doc(stranger.db, 'users', ownerId, 'pets', petId))).rejects.toThrow();
    await expect(getDocs(query(collection(stranger.db, 'shares'), where('ownerId', '==', ownerId)))).rejects.toThrow();
  });

  it('revoking an approval removes the doctor role', async () => {
    await admin.call('reviewDoctor', { uid: vetId, approve: false, note: 'Licence expired' });
    const application = await getDoc(doc(admin.db, 'doctors', vetId));
    expect(application.get('status')).toBe('rejected');
  });
});
