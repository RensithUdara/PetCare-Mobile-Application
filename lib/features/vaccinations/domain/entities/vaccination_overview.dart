import 'package:meta/meta.dart';

import 'vaccination.dart';

enum VaccinationStatus {
  upToDate('Up to date'),
  upcoming('Upcoming'),
  overdue('Overdue'),

  /// Superseded by a later dose of the same vaccine.
  completed('Completed');

  const VaccinationStatus(this.label);
  final String label;
}

/// A vaccination together with its computed status.
@immutable
class VaccinationEntry {
  const VaccinationEntry(this.vaccination, this.status);

  final Vaccination vaccination;
  final VaccinationStatus status;

  @override
  bool operator ==(Object other) =>
      other is VaccinationEntry && other.vaccination == vaccination && other.status == status;

  @override
  int get hashCode => Object.hash(vaccination, status);
}

/// Vaccinations of one pet, evaluated against "today".
@immutable
class VaccinationOverview {
  const VaccinationOverview({
    required this.current,
    required this.historyByYear,
    required this.totalRecords,
  });

  static const empty = VaccinationOverview(current: [], historyByYear: [], totalRecords: 0);

  /// Latest dose of each vaccine, most urgent first
  /// (overdue → upcoming → up to date).
  final List<VaccinationEntry> current;

  /// Every dose grouped by year administered, newest year first.
  final List<(int year, List<VaccinationEntry> entries)> historyByYear;

  final int totalRecords;

  /// Number of records with [status]. Superseded doses are never in
  /// [current], so "completed" is everything else.
  int count(VaccinationStatus status) => status == VaccinationStatus.completed
      ? totalRecords - current.length
      : current.where((e) => e.status == status).length;

  /// The nearest due date that has not passed yet.
  VaccinationEntry? get nextDue {
    for (final e in current) {
      if (e.status != VaccinationStatus.overdue && e.vaccination.nextDueDate != null) return e;
    }
    return null;
  }

  bool get hasOverdue => current.any((e) => e.status == VaccinationStatus.overdue);
}
