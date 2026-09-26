import 'package:meta/meta.dart';

import '../logic/medication_schedule.dart';
import 'medication.dart';

@immutable
class MedicationEntry {
  const MedicationEntry(this.medication, this.status, this.nextDose);

  final Medication medication;
  final MedicationStatus status;

  /// Next scheduled dose, if any.
  final DateTime? nextDose;

  @override
  bool operator ==(Object other) =>
      other is MedicationEntry &&
      other.medication == medication &&
      other.status == status &&
      other.nextDose == nextDose;

  @override
  int get hashCode => Object.hash(medication, status, nextDose);
}

/// A pet's medications grouped by status.
@immutable
class MedicationOverview {
  const MedicationOverview({
    required this.active,
    required this.upcoming,
    required this.completed,
  });

  static const empty = MedicationOverview(active: [], upcoming: [], completed: []);

  /// Soonest next dose first.
  final List<MedicationEntry> active;

  /// Soonest start first.
  final List<MedicationEntry> upcoming;

  /// Most recently finished first.
  final List<MedicationEntry> completed;

  int get total => active.length + upcoming.length + completed.length;

  /// The earliest upcoming dose across active medications.
  MedicationEntry? get nextDose {
    for (final e in active) {
      if (e.nextDose != null) return e;
    }
    return null;
  }
}
