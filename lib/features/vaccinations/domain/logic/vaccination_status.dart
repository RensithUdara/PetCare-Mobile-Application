import '../../../../core/utils/date_utils.dart';
import '../entities/vaccination.dart';
import '../entities/vaccination_overview.dart';

/// A due date within this many days counts as "upcoming".
const upcomingWindowDays = 30;

/// Status of a single dose. [superseded] means a later dose of the same
/// vaccine exists, so this one's due date no longer matters.
VaccinationStatus vaccinationStatus(
  Vaccination vaccination, {
  required DateTime now,
  bool superseded = false,
}) {
  if (superseded) return VaccinationStatus.completed;
  final due = vaccination.nextDueDate;
  if (due == null) return VaccinationStatus.upToDate;

  final days = daysBetween(now, due);
  if (days < 0) return VaccinationStatus.overdue;
  if (days <= upcomingWindowDays) return VaccinationStatus.upcoming;
  return VaccinationStatus.upToDate;
}

/// Evaluates all doses of one pet into current status + yearly history.
VaccinationOverview buildVaccinationOverview(List<Vaccination> all, DateTime now) {
  if (all.isEmpty) return VaccinationOverview.empty;

  // Newest first; ties broken by creation time so re-entered doses are stable.
  final sorted = [...all]..sort((a, b) {
      final byDate = b.dateAdministered.compareTo(a.dateAdministered);
      if (byDate != 0) return byDate;
      return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    });

  final seen = <String>{};
  final current = <VaccinationEntry>[];
  final entries = <VaccinationEntry>[];
  for (final v in sorted) {
    final isLatest = seen.add(v.vaccineKey);
    final entry = VaccinationEntry(v, vaccinationStatus(v, now: now, superseded: !isLatest));
    entries.add(entry);
    if (isLatest) current.add(entry);
  }

  current.sort(_byUrgency);

  final byYear = <int, List<VaccinationEntry>>{};
  for (final e in entries) {
    byYear.putIfAbsent(e.vaccination.dateAdministered.year, () => []).add(e);
  }
  final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

  return VaccinationOverview(
    current: current,
    historyByYear: [for (final y in years) (y, byYear[y]!)],
    totalRecords: all.length,
  );
}

int _byUrgency(VaccinationEntry a, VaccinationEntry b) {
  const rank = {
    VaccinationStatus.overdue: 0,
    VaccinationStatus.upcoming: 1,
    VaccinationStatus.upToDate: 2,
    VaccinationStatus.completed: 3,
  };
  final byRank = rank[a.status]!.compareTo(rank[b.status]!);
  if (byRank != 0) return byRank;

  // Within a group: soonest due first; no due date last; then by name.
  final aDue = a.vaccination.nextDueDate;
  final bDue = b.vaccination.nextDueDate;
  if (aDue != null && bDue != null && aDue != bDue) return aDue.compareTo(bDue);
  if (aDue == null && bDue != null) return 1;
  if (aDue != null && bDue == null) return -1;
  return a.vaccination.vaccineName.compareTo(b.vaccination.vaccineName);
}
