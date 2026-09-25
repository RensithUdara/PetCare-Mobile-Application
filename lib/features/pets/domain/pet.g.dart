// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pet _$PetFromJson(Map<String, dynamic> json) => _Pet(
  id: json['id'] as String? ?? '',
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  species: $enumDecode(
    _$PetSpeciesEnumMap,
    json['species'],
    unknownValue: PetSpecies.other,
  ),
  breed: json['breed'] as String?,
  gender:
      $enumDecodeNullable(
        _$PetGenderEnumMap,
        json['gender'],
        unknownValue: PetGender.unknown,
      ) ??
      PetGender.unknown,
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

Map<String, dynamic> _$PetToJson(_Pet instance) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'name': instance.name,
  'species': _$PetSpeciesEnumMap[instance.species]!,
  'breed': instance.breed,
  'gender': _$PetGenderEnumMap[instance.gender]!,
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

const _$PetSpeciesEnumMap = {
  PetSpecies.dog: 'dog',
  PetSpecies.cat: 'cat',
  PetSpecies.bird: 'bird',
  PetSpecies.rabbit: 'rabbit',
  PetSpecies.other: 'other',
};

const _$PetGenderEnumMap = {
  PetGender.male: 'male',
  PetGender.female: 'female',
  PetGender.unknown: 'unknown',
};
