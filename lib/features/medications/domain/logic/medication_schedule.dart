import 'package:meta/meta.dart';

import '../../../../core/utils/date_utils.dart';
import '../entities/medication.dart';

enum MedicationStatus {
  upcoming('Starts soon'),
  active('Active'),
  completed('Completed');

  const MedicationStatus(this.label);
  final String label;
}

MedicationStatus medicationStatus(Medication m, DateTime now) {
  final today = dateOnly(now);
  if (dateOnly(m.startDate).isAfter(today)) return MedicationStatus.upcoming;
  if (m.endDate != null && dateOnly(m.endDate!).isBefore(today)) return MedicationStatus.completed;
  return MedicationStatus.active;
}

/// Whether [day] falls inside the course and on a dosing day for the
/// frequency (e.g. every other day counted from the start date).
bool isDosingDay(Medication m, DateTime day) {
  if (!m.frequency.isScheduled) return false;
  final offset = daysBetween(m.startDate, day);
  if (offset < 0) return false;
  if (m.endDate != null && daysBetween(m.endDate!, day) > 0) return false;
  return offset % m.frequency.everyNDays == 0;
}

/// Scheduled dose moments on [day], in time order.
List<DateTime> dosesOn(Medication m, DateTime day) =>
    isDosingDay(m, day) ? [for (final t in [...m.doseTimes]..sort()) t.on(day)] : const [];

/// The next scheduled dose strictly after [now], or `null` if none
/// (course finished, as-needed, or no dose times configured).
DateTime? nextDose(Medication m, DateTime now) {
  if (m.doseTimes.isEmpty || !m.frequency.isScheduled) return null;
  final start = dateOnly(now).isBefore(dateOnly(m.startDate)) ? dateOnly(m.startDate) : dateOnly(now);
  // One full cycle (plus today) is enough to find the next dosing day.
  for (var i = 0; i <= m.frequency.everyNDays; i++) {
    final day = DateTime(start.year, start.month, start.day + i);
    for (final dose in dosesOn(m, day)) {
      if (dose.isAfter(now)) return dose;
    }
  }
  return null;
}

/// Progress through a fixed-length course.
@immutable
class CourseProgress {
  const CourseProgress({required this.day, required this.totalDays});

  /// 1-based day of the course (clamped to [1, totalDays]).
  final int day;
  final int totalDays;

  double get fraction => totalDays == 0 ? 1 : day / totalDays;

  int get daysLeft => totalDays - day;
}

/// `null` for ongoing medication.
CourseProgress? courseProgress(Medication m, DateTime now) {
  if (m.endDate == null) return null;
  // Guard against inconsistent stored data (end before start).
  final total = (daysBetween(m.startDate, m.endDate!) + 1).clamp(1, 1 << 30);
  final day = (daysBetween(m.startDate, now) + 1).clamp(1, total);
  return CourseProgress(day: day, totalDays: total);
}
