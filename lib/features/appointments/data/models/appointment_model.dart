import 'package:json_annotation/json_annotation.dart';

import '../../../../core/domain/reminder_offset.dart';
import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/appointment.dart';

part 'appointment_model.g.dart';

/// Firestore representation of an [Appointment]
/// (`users/{uid}/appointments/{id}`).
@JsonSerializable(includeIfNull: true)
class AppointmentModel {
  const AppointmentModel({
    this.id = '',
    required this.ownerId,
    required this.petId,
    required this.dateTime,
    this.type,
    this.status,
    this.clinic,
    this.veterinarian,
    this.reason,
    this.notes,
    this.reminderDaysBefore,
    this.reminderAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  factory AppointmentModel.fromEntity(Appointment a) => AppointmentModel(
        id: a.id,
        ownerId: a.ownerId,
        petId: a.petId,
        dateTime: a.dateTime,
        type: a.type.name,
        status: a.status.name,
        clinic: a.clinic,
        veterinarian: a.veterinarian,
        reason: a.reason,
        notes: a.notes,
        reminderDaysBefore: a.reminder?.days,
        reminderAt: a.reminderDate,
        createdAt: a.createdAt,
        updatedAt: a.updatedAt,
      );

  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String petId;
  @NullableDateTimeConverter()
  final DateTime? dateTime;
  final String? type;
  final String? status;
  final String? clinic;
  final String? veterinarian;
  final String? reason;
  final String? notes;
  final int? reminderDaysBefore;

  /// Denormalized for the server-side reminder job; `null` once the
  /// appointment is completed or cancelled.
  @NullableDateTimeConverter()
  final DateTime? reminderAt;
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  Appointment toEntity() => Appointment(
        id: id,
        ownerId: ownerId,
        petId: petId,
        dateTime: dateTime ?? createdAt ?? DateTime(1970),
        type: AppointmentType.values.asNameMap()[type] ?? AppointmentType.other,
        status: AppointmentStatus.values.asNameMap()[status] ?? AppointmentStatus.scheduled,
        clinic: clinic,
        veterinarian: veterinarian,
        reason: reason,
        notes: notes,
        reminder: ReminderOffset.fromDays(reminderDaysBefore),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
