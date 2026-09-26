// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyProfileModel _$EmergencyProfileModelFromJson(
  Map<String, dynamic> json,
) => EmergencyProfileModel(
  petId: json['petId'] as String,
  ownerId: json['ownerId'] as String,
  publicId: json['publicId'] as String,
  enabled: json['enabled'] as bool? ?? true,
  showPhoto: json['showPhoto'] as bool? ?? true,
  showBreed: json['showBreed'] as bool? ?? true,
  showMicrochip: json['showMicrochip'] as bool? ?? false,
  contactName: json['contactName'] as String?,
  contactPhone: json['contactPhone'] as String?,
  medicalWarnings: json['medicalWarnings'] as String?,
  message: json['message'] as String?,
  updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$EmergencyProfileModelToJson(
  EmergencyProfileModel instance,
) => <String, dynamic>{
  'petId': instance.petId,
  'ownerId': instance.ownerId,
  'publicId': instance.publicId,
  'enabled': instance.enabled,
  'showPhoto': instance.showPhoto,
  'showBreed': instance.showBreed,
  'showMicrochip': instance.showMicrochip,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'medicalWarnings': instance.medicalWarnings,
  'message': instance.message,
  'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
};

PublicPetProfileModel _$PublicPetProfileModelFromJson(
  Map<String, dynamic> json,
) => PublicPetProfileModel(
  publicId: json['publicId'] as String,
  ownerId: json['ownerId'] as String,
  petName: json['petName'] as String,
  species: json['species'] as String,
  breed: json['breed'] as String?,
  photoUrl: json['photoUrl'] as String?,
  microchipId: json['microchipId'] as String?,
  contactName: json['contactName'] as String?,
  contactPhone: json['contactPhone'] as String?,
  medicalWarnings: json['medicalWarnings'] as String?,
  message: json['message'] as String?,
  updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$PublicPetProfileModelToJson(
  PublicPetProfileModel instance,
) => <String, dynamic>{
  'publicId': instance.publicId,
  'ownerId': instance.ownerId,
  'petName': instance.petName,
  'species': instance.species,
  'breed': ?instance.breed,
  'photoUrl': ?instance.photoUrl,
  'microchipId': ?instance.microchipId,
  'contactName': ?instance.contactName,
  'contactPhone': ?instance.contactPhone,
  'medicalWarnings': ?instance.medicalWarnings,
  'message': ?instance.message,
  'updatedAt': ?const NullableDateTimeConverter().toJson(instance.updatedAt),
};
