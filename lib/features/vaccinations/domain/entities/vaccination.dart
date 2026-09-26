import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/reminder_offset.dart';

part 'vaccination.freezed.dart';

enum VaccineCategory {
  core('Core'),
  nonCore('Non-core'),
  other('Other');

  const VaccineCategory(this.label);
  final String label;
}

/// A single administered vaccine dose for one pet.
@freezed
abstract class Vaccination with _$Vaccination {
  const Vaccination._();

  const factory Vaccination({
    /// Empty for a record that has not been saved yet.
    @Default('') String id,
    required String ownerId,
    required String petId,
    required String vaccineName,
    @Default(VaccineCategory.core) VaccineCategory category,
    required DateTime dateAdministered,

    /// `null` for one-off vaccines that need no booster.
    DateTime? nextDueDate,
    String? veterinarian,
    String? clinic,
    String? batchNumber,
    String? notes,

    /// `null` disables the reminder.
    @Default(ReminderOffset.sevenDays) ReminderOffset? reminder,
    String? certificateUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Vaccination;

  bool get isNew => id.isEmpty;

  /// Key used to match doses of the same vaccine ("Rabies" == " rabies ").
  String get vaccineKey => vaccineName.trim().toLowerCase();

  /// When the owner should be reminded, or `null` if there is nothing to
  /// remind about.
  DateTime? get reminderDate =>
      (nextDueDate == null || reminder == null) ? null : reminder!.reminderDateFor(nextDueDate!);
}
