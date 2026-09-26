import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/reminder_offset.dart';

part 'appointment.freezed.dart';

enum AppointmentType {
  routineCheckup('Routine checkup'),
  vaccination('Vaccination'),
  dental('Dental'),
  surgery('Surgery'),
  emergency('Emergency'),
  followUp('Follow-up'),
  grooming('Grooming'),
  other('Other');

  const AppointmentType(this.label);
  final String label;
}

/// Persisted lifecycle state. See `AppointmentDisplayStatus` for what the
/// UI shows (which also depends on the current time).
enum AppointmentStatus { scheduled, completed, cancelled }

/// A veterinary appointment for one pet.
@freezed
abstract class Appointment with _$Appointment {
  const Appointment._();

  const factory Appointment({
    /// Empty for an appointment that has not been saved yet.
    @Default('') String id,
    required String ownerId,
    required String petId,

    /// Local date and time of the visit.
    required DateTime dateTime,
    @Default(AppointmentType.routineCheckup) AppointmentType type,
    @Default(AppointmentStatus.scheduled) AppointmentStatus status,
    String? clinic,
    String? veterinarian,
    String? reason,
    String? notes,

    /// `null` disables the reminder.
    @Default(ReminderOffset.oneDay) ReminderOffset? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Appointment;

  bool get isNew => id.isEmpty;

  bool get isScheduled => status == AppointmentStatus.scheduled;

  /// When to notify the owner, or `null` if no reminder applies.
  ///
  /// "On the day" fires two hours before the visit; other offsets fire the
  /// given number of days earlier at the same time of day, e.g. "Milo has a
  /// veterinary appointment tomorrow at 10:30 AM".
  DateTime? get reminderDate {
    if (reminder == null || !isScheduled) return null;
    return reminder == ReminderOffset.onTheDay
        ? dateTime.subtract(const Duration(hours: 2))
        : DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day - reminder!.days,
            dateTime.hour,
            dateTime.minute,
          );
  }
}
