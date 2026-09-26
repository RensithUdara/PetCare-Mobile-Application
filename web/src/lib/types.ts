// Shapes of the Firestore documents shared with the PetCare mobile app.
// Field names and enum values must match the app's data models exactly.

export type Role = 'admin' | 'doctor' | 'owner';

export const SPECIES = { dog: 'Dog', cat: 'Cat', bird: 'Bird', rabbit: 'Rabbit', other: 'Other' } as const;
export type Species = keyof typeof SPECIES;
export const SPECIES_EMOJI: Record<Species, string> = { dog: '🐶', cat: '🐱', bird: '🐦', rabbit: '🐰', other: '🐾' };

export const GENDERS = { male: 'Male', female: 'Female', unknown: 'Unknown' } as const;
export type Gender = keyof typeof GENDERS;

export interface Pet {
  id: string;
  ownerId: string;
  name: string;
  species: Species;
  breed?: string | null;
  gender: Gender;
  dateOfBirth?: Date | null;
  weightKg?: number | null;
  color?: string | null;
  microchipId?: string | null;
  registrationNumber?: string | null;
  notes?: string | null;
  photoUrl?: string | null;
  createdAt?: Date | null;
  updatedAt?: Date | null;
}

export const VACCINE_CATEGORIES = { core: 'Core', nonCore: 'Non-core', other: 'Other' } as const;
export type VaccineCategory = keyof typeof VACCINE_CATEGORIES;

/** Who added a record from the web doctor portal (absent for owner records). */
export interface AddedBy {
  addedByUid?: string | null;
  addedByName?: string | null;
}

export interface Vaccination extends AddedBy {
  id: string;
  ownerId: string;
  petId: string;
  vaccineName: string;
  category: VaccineCategory;
  dateAdministered: Date;
  nextDueDate?: Date | null;
  veterinarian?: string | null;
  clinic?: string | null;
  batchNumber?: string | null;
  notes?: string | null;
  reminderDaysBefore?: number | null;
}

export const APPOINTMENT_TYPES = {
  routineCheckup: 'Routine checkup',
  vaccination: 'Vaccination',
  dental: 'Dental',
  surgery: 'Surgery',
  emergency: 'Emergency',
  followUp: 'Follow-up',
  grooming: 'Grooming',
  other: 'Other',
} as const;
export type AppointmentType = keyof typeof APPOINTMENT_TYPES;
export type AppointmentStatus = 'scheduled' | 'completed' | 'cancelled';

export interface Appointment extends AddedBy {
  id: string;
  ownerId: string;
  petId: string;
  dateTime: Date;
  type: AppointmentType;
  status: AppointmentStatus;
  clinic?: string | null;
  veterinarian?: string | null;
  reason?: string | null;
  notes?: string | null;
  reminderDaysBefore?: number | null;
}

export const FREQUENCIES = {
  onceDaily: 'Once daily',
  twiceDaily: 'Twice daily',
  threeTimesDaily: 'Three times daily',
  everyOtherDay: 'Every other day',
  weekly: 'Once a week',
  asNeeded: 'As needed',
} as const;
export type Frequency = keyof typeof FREQUENCIES;

/** Default dose times per frequency, matching the app. */
export const DEFAULT_DOSE_TIMES: Record<Frequency, string[]> = {
  onceDaily: ['08:00'],
  twiceDaily: ['08:00', '20:00'],
  threeTimesDaily: ['08:00', '14:00', '20:00'],
  everyOtherDay: ['08:00'],
  weekly: ['08:00'],
  asNeeded: [],
};

export interface Medication extends AddedBy {
  id: string;
  ownerId: string;
  petId: string;
  name: string;
  dosage?: string | null;
  frequency: Frequency;
  startDate: Date;
  endDate?: Date | null;
  doseTimes: string[];
  remindersEnabled: boolean;
  instructions?: string | null;
  veterinarian?: string | null;
  notes?: string | null;
}

export interface WeightEntry {
  id: string;
  petId: string;
  date: Date;
  weightKg: number;
  note?: string | null;
}

export interface PetDocument {
  id: string;
  petId: string;
  name: string;
  type?: string | null;
  date?: Date | null;
  fileUrl: string;
  fileName: string;
  contentType: string;
  sizeBytes: number;
}

export type DoctorStatus = 'pending' | 'approved' | 'rejected';

export interface DoctorProfile {
  uid: string;
  fullName: string;
  email: string;
  phone?: string | null;
  clinicName?: string | null;
  specialization?: string | null;
  licenseNumber?: string | null;
  city?: string | null;
  bio?: string | null;
  status: DoctorStatus;
  doctorCode?: string | null;
  reviewNote?: string | null;
  createdAt?: Date | null;
  reviewedAt?: Date | null;
}

export interface PetShare {
  id: string;
  ownerId: string;
  petId: string;
  doctorId: string;
  petName: string;
  petSpecies?: Species | null;
  petPhotoUrl?: string | null;
  ownerName?: string | null;
  ownerEmail?: string | null;
  ownerPhone?: string | null;
  doctorName: string;
  clinicName?: string | null;
  doctorCode?: string | null;
  createdAt?: Date | null;
}

export interface UserProfile {
  id: string;
  fullName: string;
  email: string;
  phone?: string | null;
  city?: string | null;
  photoUrl?: string | null;
  createdAt?: Date | null;
}
