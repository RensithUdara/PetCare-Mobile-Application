import { differenceInCalendarDays, format } from 'date-fns';

export const fmtDate = (d?: Date | null) => (d ? format(d, 'MMM d, yyyy') : '—');
export const fmtDateTime = (d?: Date | null) => (d ? format(d, 'EEE, MMM d, yyyy · h:mm a') : '—');

/** `yyyy-MM-dd` for <input type="date">. */
export const toDateInput = (d?: Date | null) => (d ? format(d, 'yyyy-MM-dd') : '');
/** Local-midnight date from <input type="date">, or null when empty. */
export function fromDateInput(v: string): Date | null {
  if (!v) return null;
  const [y, m, d] = v.split('-').map(Number);
  return new Date(y, m - 1, d);
}
export const toDateTimeInput = (d?: Date | null) => (d ? format(d, "yyyy-MM-dd'T'HH:mm") : '');
export const fromDateTimeInput = (v: string): Date | null => (v ? new Date(v) : null);

/** "3 years old", "5 months old", "2 weeks old" — same rules as the app. */
export function petAge(dob: Date | null | undefined, now = new Date()): string | null {
  if (!dob) return null;
  const birth = new Date(dob.getFullYear(), dob.getMonth(), dob.getDate());
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  if (birth > today) return null;
  let months = (today.getFullYear() - birth.getFullYear()) * 12 + today.getMonth() - birth.getMonth();
  if (today.getDate() < birth.getDate()) months--;
  const plural = (n: number, unit: string) => `${n} ${unit}${n === 1 ? '' : 's'} old`;
  if (months >= 12) return plural(Math.floor(months / 12), 'year');
  if (months >= 1) return plural(months, 'month');
  const days = differenceInCalendarDays(today, birth);
  if (days >= 7) return plural(Math.floor(days / 7), 'week');
  return days === 0 ? 'Born today' : plural(days, 'day');
}

export type VaccinationStatus = 'overdue' | 'upcoming' | 'upToDate' | 'completed';

/** A due date within this many days counts as upcoming (as in the app). */
export const UPCOMING_WINDOW_DAYS = 30;

/**
 * Status of each dose. A dose is "completed" once a later dose of the same
 * vaccine exists, so only the latest dose's due date matters.
 */
export function vaccinationStatuses<T extends { id: string; vaccineName: string; dateAdministered: Date; nextDueDate?: Date | null }>(
  doses: T[],
  now = new Date(),
): Map<string, VaccinationStatus> {
  const latest = new Map<string, T>();
  for (const d of doses) {
    const key = d.vaccineName.trim().toLowerCase();
    const cur = latest.get(key);
    if (!cur || d.dateAdministered > cur.dateAdministered) latest.set(key, d);
  }
  const result = new Map<string, VaccinationStatus>();
  for (const d of doses) {
    if (latest.get(d.vaccineName.trim().toLowerCase())?.id !== d.id) {
      result.set(d.id, 'completed');
    } else if (!d.nextDueDate) {
      result.set(d.id, 'upToDate');
    } else {
      const days = differenceInCalendarDays(d.nextDueDate, now);
      result.set(d.id, days < 0 ? 'overdue' : days <= UPCOMING_WINDOW_DAYS ? 'upcoming' : 'upToDate');
    }
  }
  return result;
}

export const fmtWeight = (kg: number) => `${Number.isInteger(kg) ? kg : kg.toFixed(1)} kg`;

export function fmtBytes(n: number): string {
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${Math.round(n / 1024)} KB`;
  return `${(n / 1024 / 1024).toFixed(1)} MB`;
}
