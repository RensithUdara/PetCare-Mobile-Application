/**
 * Fills the local emulators with demo data (never touches production).
 *
 *   firebase emulators:start --only auth,firestore,functions --project demo-petcare
 *   npm --prefix web run seed
 *
 * Accounts (password: demo1234): owner@petcare.test, vet@petcare.test,
 * pending.vet@petcare.test, and admin@petcare.test (Google sign-in in the
 * emulator; claims admin through ADMIN_EMAILS in functions/.env.local).
 */
import { initializeApp } from 'firebase/app';
import {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  getAuth,
  GoogleAuthProvider,
  signInWithCredential,
  updateProfile,
} from 'firebase/auth';
import { addDoc, collection, connectFirestoreEmulator, doc, getFirestore, serverTimestamp, setDoc, Timestamp } from 'firebase/firestore';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';

const PROJECT = 'demo-petcare';
const PASSWORD = 'demo1234';

await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJECT}/accounts`, { method: 'DELETE' });
await fetch(`http://127.0.0.1:8085/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: 'DELETE' });

function client(name) {
  const app = initializeApp({ apiKey: 'demo-key', projectId: PROJECT, authDomain: `${PROJECT}.firebaseapp.com` }, name);
  const auth = getAuth(app);
  connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
  const db = getFirestore(app);
  connectFirestoreEmulator(db, '127.0.0.1', 8085);
  const fn = getFunctions(app);
  connectFunctionsEmulator(fn, '127.0.0.1', 5001);
  return { auth, db, call: async (n, data) => (await httpsCallable(fn, n)(data)).data };
}

async function signUp(c, email, fullName, phone) {
  const { user } = await createUserWithEmailAndPassword(c.auth, email, PASSWORD);
  await updateProfile(user, { displayName: fullName });
  await setDoc(doc(c.db, 'users', user.uid), { fullName, email, phone, photoUrl: null, createdAt: serverTimestamp() });
  return user.uid;
}

const day = 864e5;
const at = (offsetDays, hour = 9) => {
  const d = new Date(Date.now() + offsetDays * day);
  d.setHours(hour, 0, 0, 0);
  return Timestamp.fromDate(d);
};

// ── Admin ───────────────────────────────────────────────────────────────
const admin = client('admin');
await signInWithCredential(
  admin.auth,
  GoogleAuthProvider.credential(JSON.stringify({ sub: 'demo-admin', email: 'admin@petcare.test', email_verified: true, name: 'Ayesha Admin' })),
);
await setDoc(doc(admin.db, 'users', admin.auth.currentUser.uid), { fullName: 'Ayesha Admin', email: 'admin@petcare.test', createdAt: serverTimestamp() });
await admin.call('bootstrapAdmin');

// ── Vets ────────────────────────────────────────────────────────────────
const vet = client('vet');
const vetId = await signUp(vet, 'vet@petcare.test', 'Dr. Nimali Perera', '+94 77 555 1234');
await setDoc(doc(vet.db, 'doctors', vetId), {
  uid: vetId, fullName: 'Dr. Nimali Perera', email: 'vet@petcare.test', phone: '+94 77 555 1234',
  clinicName: 'Happy Paws Veterinary', specialization: 'Small animal medicine', licenseNumber: 'SLVC-20931',
  city: 'Colombo', bio: '12 years caring for dogs, cats and rabbits.', status: 'pending', createdAt: serverTimestamp(),
});
const { doctorCode } = await admin.call('reviewDoctor', { uid: vetId, approve: true });

const pending = client('pending');
const pendingId = await signUp(pending, 'pending.vet@petcare.test', 'Dr. Ruwan Silva', '+94 71 222 3344');
await setDoc(doc(pending.db, 'doctors', pendingId), {
  uid: pendingId, fullName: 'Dr. Ruwan Silva', email: 'pending.vet@petcare.test', phone: '+94 71 222 3344',
  clinicName: 'Kandy Pet Clinic', specialization: 'Surgery', licenseNumber: 'SLVC-18820', city: 'Kandy',
  status: 'pending', createdAt: serverTimestamp(),
});

// ── Owner with pets and records ─────────────────────────────────────────
const owner = client('owner');
const ownerId = await signUp(owner, 'owner@petcare.test', 'Kasun Silva', '+94 77 123 4567');
const pets = collection(owner.db, 'users', ownerId, 'pets');
const pet = (data) => addDoc(pets, { ownerId, photoUrl: null, createdAt: serverTimestamp(), updatedAt: serverTimestamp(), ...data });
const bruno = (await pet({ name: 'Bruno', species: 'dog', breed: 'Golden Retriever', gender: 'male', dateOfBirth: at(-3 * 365), weightKg: 28.5, color: 'Golden', microchipId: '985112004455667', notes: 'Allergic to chicken.' })).id;
const milo = (await pet({ name: 'Milo', species: 'cat', breed: 'Persian', gender: 'male', dateOfBirth: at(-400), weightKg: 4.2 })).id;
await pet({ name: 'Kiwi', species: 'bird', breed: 'Budgie', gender: 'female', dateOfBirth: at(-200) });

const rec = (kind, data) => addDoc(collection(owner.db, 'users', ownerId, kind), { ownerId, createdAt: serverTimestamp(), updatedAt: serverTimestamp(), ...data });
await rec('vaccinations', { petId: bruno, vaccineName: 'Rabies', category: 'core', dateAdministered: at(-370), nextDueDate: at(-5), reminderDaysBefore: 7, reminderAt: at(-12), veterinarian: 'Dr. Nimali Perera', clinic: 'Happy Paws Veterinary' });
await rec('vaccinations', { petId: bruno, vaccineName: 'DHPP', category: 'core', dateAdministered: at(-340), nextDueDate: at(20), reminderDaysBefore: 7, reminderAt: at(13) });
await rec('vaccinations', { petId: milo, vaccineName: 'FVRCP', category: 'core', dateAdministered: at(-100), nextDueDate: at(265), reminderDaysBefore: 7, reminderAt: at(258) });
await rec('appointments', { petId: bruno, dateTime: at(6, 10), type: 'routineCheckup', status: 'scheduled', clinic: 'Happy Paws Veterinary', veterinarian: 'Dr. Nimali Perera', reason: 'Annual checkup', reminderDaysBefore: 1, reminderAt: at(5, 10) });
await rec('appointments', { petId: bruno, dateTime: at(-60, 15), type: 'dental', status: 'completed', clinic: 'Happy Paws Veterinary', notes: 'Scaling done. Mild tartar on molars.' });
await rec('medications', { petId: bruno, name: 'Apoquel', dosage: '16 mg', frequency: 'onceDaily', startDate: at(-10), endDate: at(20), doseTimes: ['08:00'], remindersEnabled: true, instructions: 'Give with food' });
for (const [d, kg] of [[-300, 25.1], [-200, 26.4], [-120, 27.2], [-40, 28.0], [-5, 28.5]]) {
  await rec('weights', { petId: bruno, date: at(d), weightKg: kg });
}

// Bruno is shared with Dr. Nimali.
await setDoc(doc(owner.db, 'shares', `${ownerId}_${bruno}_${vetId}`), {
  ownerId, petId: bruno, doctorId: vetId, petName: 'Bruno', petSpecies: 'dog', petPhotoUrl: null,
  ownerName: 'Kasun Silva', ownerEmail: 'owner@petcare.test', ownerPhone: '+94 77 123 4567',
  doctorName: 'Dr. Nimali Perera', clinicName: 'Happy Paws Veterinary', doctorCode, createdAt: serverTimestamp(),
});

console.log(`Seeded. Vet code: ${doctorCode}. Password for email accounts: ${PASSWORD}`);
process.exit(0);
