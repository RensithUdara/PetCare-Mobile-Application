import 'package:freezed_annotation/freezed_annotation.dart';

import 'dose_time.dart';

part 'medication.freezed.dart';

enum MedicationFrequency {
  onceDaily('Once daily', dosesPerDay: 1, everyNDays: 1),
  twiceDaily('Twice daily', dosesPerDay: 2, everyNDays: 1),
  threeTimesDaily('Three times daily', dosesPerDay: 3, everyNDays: 1),
  everyOtherDay('Every other day', dosesPerDay: 1, everyNDays: 2),
  weekly('Once a week', dosesPerDay: 1, everyNDays: 7),
  asNeeded('As needed', dosesPerDay: 0, everyNDays: 0);

  const MedicationFrequency(this.label, {required this.dosesPerDay, required this.everyNDays});

  final String label;

  /// Suggested number of reminder times on a dosing day.
  final int dosesPerDay;

  /// Dosing days repeat every N days counted from the start date
  /// (0 = no fixed schedule).
  final int everyNDays;

  bool get isScheduled => everyNDays > 0;

  /// Sensible default reminder times for this frequency.
  List<DoseTime> get defaultTimes => switch (dosesPerDay) {
        0 => const [],
        1 => const [DoseTime(8, 0)],
        2 => const [DoseTime(8, 0), DoseTime(20, 0)],
        _ => const [DoseTime(8, 0), DoseTime(14, 0), DoseTime(20, 0)],
      };
}

/// A course of medication for one pet.
@freezed
abstract class Medication with _$Medication {
  const Medication._();

  const factory Medication({
    /// Empty for a medication that has not been saved yet.
    @Default('') String id,
    required String ownerId,
    required String petId,
    required String name,

    /// Free text, e.g. "1 tablet", "5 ml", "½ chew".
    required String dosage,
    @Default(MedicationFrequency.onceDaily) MedicationFrequency frequency,

    /// First dosing day (date only).
    required DateTime startDate,

    /// Last dosing day, inclusive; `null` for ongoing medication.
    DateTime? endDate,

    /// Times of day for doses, sorted.
    @Default(<DoseTime>[]) List<DoseTime> doseTimes,
    @Default(true) bool remindersEnabled,
    String? instructions,
    String? veterinarian,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Medication;

  bool get isNew => id.isEmpty;

  bool get isOngoing => endDate == null;
}
