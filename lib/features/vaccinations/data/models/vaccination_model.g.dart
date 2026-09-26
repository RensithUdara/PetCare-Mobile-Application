// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VaccinationModel _$VaccinationModelFromJson(
  Map<String, dynamic> json,
) => VaccinationModel(
  id: json['id'] as String? ?? '',
  ownerId: json['ownerId'] as String,
  petId: json['petId'] as String,
  vaccineName: json['vaccineName'] as String,
  category: json['category'] as String?,
  dateAdministered: const NullableDateTimeConverter().fromJson(
    json['dateAdministered'],
  ),
  nextDueDate: const NullableDateTimeConverter().fromJson(json['nextDueDate']),
  veterinarian: json['veterinarian'] as String?,
  clinic: json['clinic'] as String?,
  batchNumber: json['batchNumber'] as String?,
  notes: json['notes'] as String?,
  reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt(),
  reminderAt: const NullableDateTimeConverter().fromJson(json['reminderAt']),
  certificateUrl: json['certificateUrl'] as String?,
  createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$VaccinationModelToJson(
  VaccinationModel instance,
) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'petId': instance.petId,
  'vaccineName': instance.vaccineName,
  'category': instance.category,
  'dateAdministered': const NullableDateTimeConverter().toJson(
    instance.dateAdministered,
  ),
  'nextDueDate': const NullableDateTimeConverter().toJson(instance.nextDueDate),
  'veterinarian': instance.veterinarian,
  'clinic': instance.clinic,
  'batchNumber': instance.batchNumber,
  'notes': instance.notes,
  'reminderDaysBefore': instance.reminderDaysBefore,
  'reminderAt': const NullableDateTimeConverter().toJson(instance.reminderAt),
  'certificateUrl': instance.certificateUrl,
  'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
};
