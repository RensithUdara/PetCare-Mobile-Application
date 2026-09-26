import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  limit,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
  type DocumentData,
} from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';

import {
  appointmentToDoc,
  clean,
  doctorFromDoc,
  medicationToDoc,
  petToDoc,
  vaccinationToDoc,
} from './converters';
import { db, functions } from './firebase';
import type {
  Appointment,
  DoctorProfile,
  Medication,
  Pet,
  PetShare,
  Role,
  UserProfile,
  Vaccination,
} from './types';

// ── Paths ───────────────────────────────────────────────────────────────
export type RecordKind = 'vaccinations' | 'appointments' | 'medications' | 'documents' | 'weights';
export const RECORD_KINDS: RecordKind[] = ['vaccinations', 'appointments', 'medications', 'documents', 'weights'];

export const userDoc = (uid: string) => doc(db, 'users', uid);
export const petsCol = (uid: string) => collection(db, 'users', uid, 'pets');
export const petDoc = (uid: string, petId: string) => doc(db, 'users', uid, 'pets', petId);
export const recordsCol = (uid: string, kind: RecordKind) => collection(db, 'users', uid, kind);
/** A pet's records; doctors must always filter by pet (security rules). */
export const petRecords = (uid: string, kind: RecordKind, petId: string) =>
  query(recordsCol(uid, kind), where('petId', '==', petId));
export const doctorDoc = (uid: string) => doc(db, 'doctors', uid);
export const sharesCol = () => collection(db, 'shares');
export const shareId = (ownerId: string, petId: string, doctorId: string) => `${ownerId}_${petId}_${doctorId}`;

// ── Owner: pets ─────────────────────────────────────────────────────────
export async function savePet(uid: string, pet: Omit<Pet, 'id' | 'ownerId'>, id?: string): Promise<string> {
  const data = petToDoc({ ...pet, ownerId: uid }, !id);
  if (id) {
    await setDoc(petDoc(uid, id), data, { merge: true });
    return id;
  }
  return (await addDoc(petsCol(uid), data)).id;
}

/**
 * Deletes a pet with its records, vet shares and QR pages (like the app).
 * Photos and uploaded files stay in Storage; delete from the app to remove them.
 */
export async function deletePet(uid: string, petId: string): Promise<void> {
  const refs = [];
  for (const kind of RECORD_KINDS) {
    refs.push(...(await getDocs(petRecords(uid, kind, petId))).docs.map((d) => d.ref));
  }
  const shares = await getDocs(query(sharesCol(), where('ownerId', '==', uid), where('petId', '==', petId)));
  refs.push(...shares.docs.map((d) => d.ref));
  const emergency = await getDoc(doc(db, 'users', uid, 'emergencyProfiles', petId));
  if (emergency.exists()) {
    const publicId = emergency.get('publicId') as string | undefined;
    if (publicId) refs.push(doc(db, 'publicProfiles', publicId));
    refs.push(emergency.ref);
  }
  for (let i = 0; i < refs.length; i += 450) {
    const batch = writeBatch(db);
    refs.slice(i, i + 450).forEach((r) => batch.delete(r));
    await batch.commit();
  }
  await deleteDoc(petDoc(uid, petId));
}

// ── Records (owners, and doctors for shared pets) ────────────────────────
type NewOrExisting<T> = Omit<T, 'id'> & { id?: string };

async function saveRecord(ownerId: string, kind: RecordKind, data: DocumentData, id?: string): Promise<string> {
  if (id) {
    await setDoc(doc(recordsCol(ownerId, kind), id), data, { merge: true });
    return id;
  }
  return (await addDoc(recordsCol(ownerId, kind), data)).id;
}

export const saveVaccination = ({ id, ...v }: NewOrExisting<Vaccination>) =>
  saveRecord(v.ownerId, 'vaccinations', vaccinationToDoc(v, !id), id);
export const saveAppointment = ({ id, ...a }: NewOrExisting<Appointment>) =>
  saveRecord(a.ownerId, 'appointments', appointmentToDoc(a, !id), id);
export const saveMedication = ({ id, ...m }: NewOrExisting<Medication>) =>
  saveRecord(m.ownerId, 'medications', medicationToDoc(m, !id), id);
export const deleteRecord = (ownerId: string, kind: RecordKind, id: string) =>
  deleteDoc(doc(recordsCol(ownerId, kind), id));

// ── Profiles ────────────────────────────────────────────────────────────
export const updateProfile = (uid: string, p: Pick<UserProfile, 'fullName' | 'phone' | 'city'>) =>
  setDoc(
    userDoc(uid),
    { fullName: p.fullName.trim(), phone: clean(p.phone), city: clean(p.city), updatedAt: serverTimestamp() },
    { merge: true },
  );

/** Creates the `users/{uid}` profile the app expects (same shape). */
export const createProfile = (uid: string, p: { fullName: string; email: string; phone?: string | null }) =>
  setDoc(
    userDoc(uid),
    { fullName: p.fullName.trim(), email: p.email, phone: clean(p.phone), photoUrl: null, createdAt: serverTimestamp() },
    { merge: true },
  );

// ── Doctors ─────────────────────────────────────────────────────────────
export type DoctorApplication = Pick<
  DoctorProfile,
  'fullName' | 'email' | 'phone' | 'clinicName' | 'specialization' | 'licenseNumber' | 'city' | 'bio'
>;

export const applyAsDoctor = (uid: string, a: DoctorApplication) =>
  setDoc(doctorDoc(uid), {
    uid,
    fullName: a.fullName.trim(),
    email: a.email,
    phone: clean(a.phone),
    clinicName: clean(a.clinicName),
    specialization: clean(a.specialization),
    licenseNumber: clean(a.licenseNumber),
    city: clean(a.city),
    bio: clean(a.bio),
    status: 'pending',
    createdAt: serverTimestamp(),
  });

export const updateDoctorProfile = (uid: string, a: Omit<DoctorApplication, 'email'>) =>
  updateDoc(doctorDoc(uid), {
    fullName: a.fullName.trim(),
    phone: clean(a.phone),
    clinicName: clean(a.clinicName),
    specialization: clean(a.specialization),
    licenseNumber: clean(a.licenseNumber),
    city: clean(a.city),
    bio: clean(a.bio),
    updatedAt: serverTimestamp(),
  });

/** Normalises typed input into a doctor code like `DR-7K3M9Q` (same rules as the app). */
export function normalizeDoctorCode(input: string): string | null {
  let code = input.toUpperCase().replace(/[\s_]/g, '');
  if (code.startsWith('DR-')) code = code.slice(3);
  else if (code.startsWith('DR')) code = code.slice(2);
  code = code.replace(/-/g, '');
  return /^[A-HJ-NP-Z2-9]{6}$/.test(code) ? `DR-${code}` : null;
}

export async function findDoctorByCode(input: string): Promise<DoctorProfile> {
  const code = normalizeDoctorCode(input);
  if (!code) throw new Error('Doctor codes look like DR-7K3M9Q. Check the code and try again.');
  const snap = await getDocs(
    query(collection(db, 'doctors'), where('doctorCode', '==', code), where('status', '==', 'approved'), limit(1)),
  );
  if (snap.empty) throw new Error(`No approved vet found with code ${code}.`);
  return doctorFromDoc(snap.docs[0].id, snap.docs[0].data());
}

// ── Shares ──────────────────────────────────────────────────────────────
export async function sharePet(owner: UserProfile, pet: Pet, doctor: DoctorProfile): Promise<void> {
  const id = shareId(owner.id, pet.id, doctor.uid);
  if ((await getDocs(query(sharesCol(), where('ownerId', '==', owner.id), where('petId', '==', pet.id)))).docs.some(
    (d) => d.id === id,
  )) {
    throw new Error(`${doctor.fullName} already has access to ${pet.name}.`);
  }
  await setDoc(doc(sharesCol(), id), {
    ownerId: owner.id,
    petId: pet.id,
    doctorId: doctor.uid,
    petName: pet.name,
    petSpecies: pet.species,
    petPhotoUrl: pet.photoUrl ?? null,
    ownerName: owner.fullName || null,
    ownerEmail: owner.email || null,
    ownerPhone: owner.phone ?? null,
    doctorName: doctor.fullName,
    clinicName: doctor.clinicName ?? null,
    doctorCode: doctor.doctorCode ?? null,
    createdAt: serverTimestamp(),
  } satisfies Omit<PetShare, 'id' | 'createdAt'> & { createdAt: unknown });
}

export const revokeShare = (id: string) => deleteDoc(doc(sharesCol(), id));

// ── Admin (Cloud Functions) ─────────────────────────────────────────────
export interface AdminUser {
  uid: string;
  email: string | null;
  displayName: string | null;
  role: Role;
  disabled: boolean;
  createdAt: string | null;
  lastSignInAt: string | null;
}

export interface AdminStats {
  users: number;
  pets: number;
  vaccinations: number;
  appointments: number;
  medications: number;
  documents: number;
  shares: number;
  doctors: { approved: number; pending: number; rejected: number };
}

const call = <Req, Res>(name: string) => async (data: Req): Promise<Res> =>
  (await httpsCallable<Req, Res>(functions, name)(data)).data;

export const adminApi = {
  stats: call<void, AdminStats>('adminStats'),
  listUsers: call<{ pageToken?: string }, { users: AdminUser[]; nextPageToken: string | null }>('listUsers'),
  setUserRole: call<{ uid: string; role: Role }, { role: Role }>('setUserRole'),
  setUserDisabled: call<{ uid: string; disabled: boolean }, { disabled: boolean }>('setUserDisabled'),
  reviewDoctor: call<{ uid: string; approve: boolean; note?: string }, { status: string; doctorCode?: string }>(
    'reviewDoctor',
  ),
  bootstrapAdmin: call<void, { role: Role }>('bootstrapAdmin'),
};

/** A readable message for Firebase / callable errors. */
export function errorMessage(e: unknown): string {
  const err = e as { code?: string; message?: string };
  switch (err?.code) {
    case 'auth/invalid-credential':
    case 'auth/wrong-password':
    case 'auth/user-not-found':
      return 'Incorrect email or password.';
    case 'auth/email-already-in-use':
      return 'An account already exists with this email.';
    case 'auth/weak-password':
      return 'Please choose a stronger password (at least 8 characters).';
    case 'auth/too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'auth/popup-closed-by-user':
      return 'Sign-in was cancelled.';
    case 'auth/network-request-failed':
    case 'unavailable':
      return 'No internet connection. Check your network and try again.';
    case 'permission-denied':
    case 'functions/permission-denied':
      return err.message && err.code?.startsWith('functions/') ? err.message : 'You don’t have permission to do that.';
    default:
      return err?.message?.replace(/^Firebase: /, '').replace(/ \(.*\)\.?$/, '') || 'Something went wrong. Please try again.';
  }
}
