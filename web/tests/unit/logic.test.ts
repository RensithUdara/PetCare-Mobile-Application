import { Timestamp } from 'firebase/firestore';
import { describe, expect, it } from 'vitest';

import { appointmentToDoc, medicationToDoc, vaccinationToDoc } from '../../src/lib/converters';
import { normalizeDoctorCode } from '../../src/lib/doctorCode';
import { petAge, vaccinationStatuses } from '../../src/lib/format';
import { reminderAtFor } from '../../src/lib/reminders';

describe('reminderAtFor (must match the mobile app)', () => {
  it('vaccinations remind at 9:00, N days before', () => {
    expect(reminderAtFor('vaccination', new Date(2026, 9, 10), 7)).toEqual(new Date(2026, 9, 3, 9, 0));
    expect(reminderAtFor('vaccination', new Date(2026, 9, 10, 15, 30), 0)).toEqual(new Date(2026, 9, 10, 9, 0));
  });
  it('appointments remind at the same time N days before, or 2 hours before on the day', () => {
    const at = new Date(2026, 9, 10, 14, 30);
    expect(reminderAtFor('appointment', at, 1)).toEqual(new Date(2026, 9, 9, 14, 30));
    expect(reminderAtFor('appointment', at, 0)).toEqual(new Date(2026, 9, 10, 12, 30));
  });
  it('no reminder without a date or offset', () => {
    expect(reminderAtFor('vaccination', null, 7)).toBeNull();
    expect(reminderAtFor('appointment', new Date(), null)).toBeNull();
  });
});

describe('normalizeDoctorCode', () => {
  it('accepts sloppy input, rejects nonsense', () => {
    expect(normalizeDoctorCode(' dr-7k3m9q ')).toBe('DR-7K3M9Q');
    expect(normalizeDoctorCode('7K3M9Q')).toBe('DR-7K3M9Q');
    expect(normalizeDoctorCode('DR 7K3 M9Q')).toBe('DR-7K3M9Q');
    expect(normalizeDoctorCode('DR-7K3M0Q')).toBeNull();
    expect(normalizeDoctorCode('hello')).toBeNull();
  });
});

describe('petAge (same labels as the app)', () => {
  const now = new Date(2026, 8, 26);
  it('formats years, months, weeks and days', () => {
    expect(petAge(new Date(2023, 8, 26), now)).toBe('3 years old');
    expect(petAge(new Date(2025, 8, 27), now)).toBe('11 months old');
    expect(petAge(new Date(2026, 8, 5), now)).toBe('3 weeks old');
    expect(petAge(new Date(2026, 8, 24), now)).toBe('2 days old');
    expect(petAge(new Date(2026, 8, 26), now)).toBe('Born today');
    expect(petAge(new Date(2027, 0, 1), now)).toBeNull();
  });
});

describe('vaccinationStatuses', () => {
  const now = new Date(2026, 8, 26);
  it('only the latest dose of a vaccine counts; older ones are completed', () => {
    const s = vaccinationStatuses(
      [
        { id: 'old', vaccineName: 'Rabies', dateAdministered: new Date(2024, 8, 1), nextDueDate: new Date(2025, 8, 1) },
        { id: 'new', vaccineName: 'rabies ', dateAdministered: new Date(2025, 8, 20), nextDueDate: new Date(2026, 8, 20) },
        { id: 'soon', vaccineName: 'DHPP', dateAdministered: new Date(2025, 9, 1), nextDueDate: new Date(2026, 9, 10) },
        { id: 'fine', vaccineName: 'Lepto', dateAdministered: new Date(2026, 1, 1), nextDueDate: new Date(2027, 1, 1) },
      ],
      now,
    );
    expect(s.get('old')).toBe('completed');
    expect(s.get('new')).toBe('overdue');
    expect(s.get('soon')).toBe('upcoming');
    expect(s.get('fine')).toBe('upToDate');
  });
});

describe('converters write the fields the app reads', () => {
  it('vaccination: trims, nulls blanks, stores reminder moment and who added it', () => {
    const doc = vaccinationToDoc(
      {
        ownerId: 'u1',
        petId: 'bruno',
        vaccineName: ' Rabies ',
        category: 'core',
        dateAdministered: new Date(2026, 8, 1),
        nextDueDate: new Date(2027, 8, 1),
        reminderDaysBefore: 7,
        veterinarian: '  ',
        addedByUid: 'doc1',
        addedByName: 'Dr. Nimali',
      },
      true,
    );
    expect(doc.vaccineName).toBe('Rabies');
    expect(doc.veterinarian).toBeNull();
    expect(doc.reminderDaysBefore).toBe(7);
    expect((doc.reminderAt as Timestamp).toDate()).toEqual(new Date(2027, 7, 25, 9, 0));
    expect(doc.addedByUid).toBe('doc1');
    expect(doc).toHaveProperty('createdAt');
  });

  it('completed visits have no reminder; owner records have no addedBy', () => {
    const doc = appointmentToDoc(
      { ownerId: 'u1', petId: 'bruno', dateTime: new Date(2026, 8, 1, 10), type: 'dental', status: 'completed', reminderDaysBefore: 1, notes: 'Cleaned' },
      true,
    );
    expect(doc.reminderAt).toBeNull();
    expect(doc.reminderDaysBefore).toBeNull();
    expect(doc).not.toHaveProperty('addedByUid');
  });

  it('as-needed medications have no dose times or reminders', () => {
    const doc = medicationToDoc(
      { ownerId: 'u1', petId: 'bruno', name: 'Pain relief', frequency: 'asNeeded', startDate: new Date(), doseTimes: ['08:00'], remindersEnabled: true },
      false,
    );
    expect(doc.doseTimes).toEqual([]);
    expect(doc.remindersEnabled).toBe(false);
    expect(doc).not.toHaveProperty('createdAt');
  });
});
