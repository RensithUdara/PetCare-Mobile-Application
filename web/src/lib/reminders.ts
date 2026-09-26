/** Reminder choices, in days before the due date (matches the app). */
export const REMINDER_OPTIONS = [
  { days: 0, vaccination: 'On the day', appointment: '2 hours before' },
  { days: 1, vaccination: '1 day before', appointment: '1 day before' },
  { days: 3, vaccination: '3 days before', appointment: '3 days before' },
  { days: 7, vaccination: '7 days before', appointment: '7 days before' },
  { days: 14, vaccination: '14 days before', appointment: '14 days before' },
] as const;

/**
 * When the owner's app will remind them — must match the mobile app so
 * the server-side fallback push agrees with local notifications:
 *
 * * vaccinations: 9:00 on the reminder day;
 * * appointments: same time of day, N days before (or 2 hours before for
 *   "on the day").
 */
export function reminderAtFor(kind: 'vaccination' | 'appointment', due: Date | null, days: number | null): Date | null {
  if (!due || days === null || days === undefined) return null;
  if (kind === 'vaccination') {
    return new Date(due.getFullYear(), due.getMonth(), due.getDate() - days, 9, 0);
  }
  if (days === 0) return new Date(due.getTime() - 2 * 60 * 60 * 1000);
  return new Date(due.getFullYear(), due.getMonth(), due.getDate() - days, due.getHours(), due.getMinutes());
}
