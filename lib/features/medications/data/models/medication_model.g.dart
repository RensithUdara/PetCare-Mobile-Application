// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationModel _$MedicationModelFromJson(Map<String, dynamic> json) =>
    MedicationModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      petId: json['petId'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String?,
      startDate: const NullableDateTimeConverter().fromJson(json['startDate']),
      endDate: const NullableDateTimeConverter().fromJson(json['endDate']),
      doseTimes:
          (json['doseTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      remindersEnabled: json['remindersEnabled'] as bool? ?? true,
      instructions: json['instructions'] as String?,
      veterinarian: json['veterinarian'] as String?,
      notes: json['notes'] as String?,
      createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
      updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$MedicationModelToJson(MedicationModel instance) =>
    <String, dynamic>{
      'ownerId': instance.ownerId,
      'petId': instance.petId,
      'name': instance.name,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'startDate': const NullableDateTimeConverter().toJson(instance.startDate),
      'endDate': const NullableDateTimeConverter().toJson(instance.endDate),
      'doseTimes': instance.doseTimes,
      'remindersEnabled': instance.remindersEnabled,
      'instructions': instance.instructions,
      'veterinarian': instance.veterinarian,
      'notes': instance.notes,
      'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
    };
