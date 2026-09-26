// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      petId: json['petId'] as String,
      dateTime: const NullableDateTimeConverter().fromJson(json['dateTime']),
      type: json['type'] as String?,
      status: json['status'] as String?,
      clinic: json['clinic'] as String?,
      veterinarian: json['veterinarian'] as String?,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt(),
      reminderAt: const NullableDateTimeConverter().fromJson(
        json['reminderAt'],
      ),
      createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
      updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$AppointmentModelToJson(
  AppointmentModel instance,
) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'petId': instance.petId,
  'dateTime': const NullableDateTimeConverter().toJson(instance.dateTime),
  'type': instance.type,
  'status': instance.status,
  'clinic': instance.clinic,
  'veterinarian': instance.veterinarian,
  'reason': instance.reason,
  'notes': instance.notes,
  'reminderDaysBefore': instance.reminderDaysBefore,
  'reminderAt': const NullableDateTimeConverter().toJson(instance.reminderAt),
  'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
};
