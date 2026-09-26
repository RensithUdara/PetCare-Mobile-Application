// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetModel _$PetModelFromJson(Map<String, dynamic> json) => PetModel(
  id: json['id'] as String? ?? '',
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  species: json['species'] as String,
  breed: json['breed'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: const NullableDateTimeConverter().fromJson(json['dateOfBirth']),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  color: json['color'] as String?,
  microchipId: json['microchipId'] as String?,
  registrationNumber: json['registrationNumber'] as String?,
  notes: json['notes'] as String?,
  photoUrl: json['photoUrl'] as String?,
  createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$PetModelToJson(PetModel instance) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'name': instance.name,
  'species': instance.species,
  'breed': instance.breed,
  'gender': instance.gender,
  'dateOfBirth': const NullableDateTimeConverter().toJson(instance.dateOfBirth),
  'weightKg': instance.weightKg,
  'color': instance.color,
  'microchipId': instance.microchipId,
  'registrationNumber': instance.registrationNumber,
  'notes': instance.notes,
  'photoUrl': instance.photoUrl,
  'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
};
