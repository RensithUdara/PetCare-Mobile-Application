import { serverTimestamp, Timestamp, type DocumentData } from 'firebase/firestore';

import { reminderAtFor } from './reminders';
import type {
  Appointment,
  DoctorProfile,
  Medication,
  Pet,
  PetDocument,
  PetShare,
  UserProfile,
  Vaccination,
  WeightEntry,
} from './types';

// Firestore ↔ app types. Reads are tolerant (like the mobile app); writes
// produce exactly the fields the app's models expect.

export const toDate = (v: unknown): Date | null => (v instanceof Timestamp ? v.toDate() : null);
const ts = (d: Date | null | undefined) => (d ? Timestamp.fromDate(d) : null);
const str = (v: unknown) => (typeof v === 'string' && v.trim() !== '' ? v : null);
/** Trims text fields; blanks become null. */
export const clean = (v: string | null | undefined) => (v && v.trim() ? v.trim() : null);

export function petFromDoc(id: string, d: DocumentData): Pet {
  return {
    id,
    ownerId: d.ownerId,
    name: d.name ?? '',
    species: d.species ?? 'other',
    breed: str(d.breed),
    gender: d.gender ?? 'unknown',
    dateOfBirth: toDate(d.dateOfBirth),
    weightKg: typeof d.weightKg === 'number' ? d.weightKg : null,
    color: str(d.color),
    microchipId: str(d.microchipId),
    registrationNumber: str(d.registrationNumber),
    notes: str(d.notes),
    photoUrl: str(d.photoUrl),
    createdAt: toDate(d.createdAt),
    updatedAt: toDate(d.updatedAt),
  };
}

export function petToDoc(p: Omit<Pet, 'id'>, isNew: boolean): DocumentData {
  return {
    ownerId: p.ownerId,
    name: p.name.trim(),
    species: p.species,
    breed: clean(p.breed),
    gender: p.gender,
    dateOfBirth: ts(p.dateOfBirth),
    weightKg: p.weightKg ?? null,
    color: clean(p.color),
    microchipId: clean(p.microchipId),
    registrationNumber: clean(p.registrationNumber),
    notes: clean(p.notes),
    photoUrl: p.photoUrl ?? null,
    ...(isNew ? { createdAt: serverTimestamp() } : {}),
    updatedAt: serverTimestamp(),
  };
}

const addedBy = (d: DocumentData) => ({ addedByUid: str(d.addedByUid), addedByName: str(d.addedByName) });

export function vaccinationFromDoc(id: string, d: DocumentData): Vaccination {
  return {
    id,
    ownerId: d.ownerId,
    petId: d.petId,
    vaccineName: d.vaccineName ?? '',
    category: d.category ?? 'other',
    dateAdministered: toDate(d.dateAdministered) ?? toDate(d.createdAt) ?? new Date(0),
    nextDueDate: toDate(d.nextDueDate),
    veterinarian: str(d.veterinarian),
    clinic: str(d.clinic),
    batchNumber: str(d.batchNumber),
    notes: str(d.notes),
    reminderDaysBefore: typeof d.reminderDaysBefore === 'number' ? d.reminderDaysBefore : null,
    ...addedBy(d),
  };
}

export function vaccinationToDoc(v: Omit<Vaccination, 'id'>, isNew: boolean): DocumentData {
  return {
    ownerId: v.ownerId,
    petId: v.petId,
    vaccineName: v.vaccineName.trim(),
    category: v.category,
    dateAdministered: ts(v.dateAdministered),
    nextDueDate: ts(v.nextDueDate),
    veterinarian: clean(v.veterinarian),
    clinic: clean(v.clinic),
    batchNumber: clean(v.batchNumber),
    notes: clean(v.notes),
    reminderDaysBefore: v.nextDueDate ? v.reminderDaysBefore ?? null : null,
    reminderAt: ts(reminderAtFor('vaccination', v.nextDueDate ?? null, v.reminderDaysBefore ?? null)),
    certificateUrl: null,
    ...(v.addedByUid ? { addedByUid: v.addedByUid, addedByName: v.addedByName ?? null } : {}),
    ...(isNew ? { createdAt: serverTimestamp() } : {}),
    updatedAt: serverTimestamp(),
  };
}

export function appointmentFromDoc(id: string, d: DocumentData): Appointment {
  return {
    id,
    ownerId: d.ownerId,
    petId: d.petId,
    dateTime: toDate(d.dateTime) ?? new Date(0),
    type: d.type ?? 'other',
    status: d.status ?? 'scheduled',
    clinic: str(d.clinic),
    veterinarian: str(d.veterinarian),
    reason: str(d.reason),
    notes: str(d.notes),
    reminderDaysBefore: typeof d.reminderDaysBefore === 'number' ? d.reminderDaysBefore : null,
    ...addedBy(d),
  };
}

export function appointmentToDoc(a: Omit<Appointment, 'id'>, isNew: boolean): DocumentData {
  const scheduled = a.status === 'scheduled';
  return {
    ownerId: a.ownerId,
    petId: a.petId,
    dateTime: ts(a.dateTime),
    type: a.type,
    status: a.status,
    clinic: clean(a.clinic),
    veterinarian: clean(a.veterinarian),
    reason: clean(a.reason),
    notes: clean(a.notes),
    reminderDaysBefore: scheduled ? a.reminderDaysBefore ?? null : null,
    reminderAt: scheduled ? ts(reminderAtFor('appointment', a.dateTime, a.reminderDaysBefore ?? null)) : null,
    ...(a.addedByUid ? { addedByUid: a.addedByUid, addedByName: a.addedByName ?? null } : {}),
    ...(isNew ? { createdAt: serverTimestamp() } : {}),
    updatedAt: serverTimestamp(),
  };
}

export function medicationFromDoc(id: string, d: DocumentData): Medication {
  return {
    id,
    ownerId: d.ownerId,
    petId: d.petId,
    name: d.name ?? '',
    dosage: str(d.dosage),
    frequency: d.frequency ?? 'onceDaily',
    startDate: toDate(d.startDate) ?? new Date(0),
    endDate: toDate(d.endDate),
    doseTimes: Array.isArray(d.doseTimes) ? d.doseTimes : [],
    remindersEnabled: d.remindersEnabled !== false,
    instructions: str(d.instructions),
    veterinarian: str(d.veterinarian),
    notes: str(d.notes),
    ...addedBy(d),
  };
}

export function medicationToDoc(m: Omit<Medication, 'id'>, isNew: boolean): DocumentData {
  return {
    ownerId: m.ownerId,
    petId: m.petId,
    name: m.name.trim(),
    dosage: clean(m.dosage),
    frequency: m.frequency,
    startDate: ts(m.startDate),
    endDate: ts(m.endDate),
    doseTimes: m.frequency === 'asNeeded' ? [] : m.doseTimes,
    remindersEnabled: m.frequency !== 'asNeeded' && m.remindersEnabled,
    instructions: clean(m.instructions),
    veterinarian: clean(m.veterinarian),
    notes: clean(m.notes),
    ...(m.addedByUid ? { addedByUid: m.addedByUid, addedByName: m.addedByName ?? null } : {}),
    ...(isNew ? { createdAt: serverTimestamp() } : {}),
    updatedAt: serverTimestamp(),
  };
}

export function weightFromDoc(id: string, d: DocumentData): WeightEntry {
  return { id, petId: d.petId, date: toDate(d.date) ?? new Date(0), weightKg: Number(d.weightKg ?? 0), note: str(d.note) };
}

export function documentFromDoc(id: string, d: DocumentData): PetDocument {
  return {
    id,
    petId: d.petId,
    name: d.name ?? 'Document',
    type: str(d.type),
    date: toDate(d.date),
    fileUrl: d.fileUrl,
    fileName: d.fileName ?? '',
    contentType: d.contentType ?? '',
    sizeBytes: Number(d.sizeBytes ?? 0),
  };
}

export function doctorFromDoc(id: string, d: DocumentData): DoctorProfile {
  return {
    uid: id,
    fullName: d.fullName ?? 'Veterinarian',
    email: d.email ?? '',
    phone: str(d.phone),
    clinicName: str(d.clinicName),
    specialization: str(d.specialization),
    licenseNumber: str(d.licenseNumber),
    city: str(d.city),
    bio: str(d.bio),
    status: d.status ?? 'pending',
    doctorCode: str(d.doctorCode),
    reviewNote: str(d.reviewNote),
    createdAt: toDate(d.createdAt),
    reviewedAt: toDate(d.reviewedAt),
  };
}

export function shareFromDoc(id: string, d: DocumentData): PetShare {
  return {
    id,
    ownerId: d.ownerId,
    petId: d.petId,
    doctorId: d.doctorId,
    petName: d.petName ?? '',
    petSpecies: d.petSpecies ?? null,
    petPhotoUrl: str(d.petPhotoUrl),
    ownerName: str(d.ownerName),
    ownerEmail: str(d.ownerEmail),
    ownerPhone: str(d.ownerPhone),
    doctorName: d.doctorName ?? 'Veterinarian',
    clinicName: str(d.clinicName),
    doctorCode: str(d.doctorCode),
    createdAt: toDate(d.createdAt),
  };
}

export function profileFromDoc(id: string, d: DocumentData): UserProfile {
  return {
    id,
    fullName: d.fullName ?? '',
    email: d.email ?? '',
    phone: str(d.phone),
    city: str(d.city),
    photoUrl: str(d.photoUrl),
    createdAt: toDate(d.createdAt),
  };
}
