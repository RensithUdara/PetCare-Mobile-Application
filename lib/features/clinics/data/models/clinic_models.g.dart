// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClinicModel _$ClinicModelFromJson(Map<String, dynamic> json) => ClinicModel(
  id: json['id'] as String? ?? '',
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  openingHours: json['openingHours'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ClinicModelToJson(ClinicModel instance) =>
    <String, dynamic>{
      'ownerId': instance.ownerId,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'openingHours': instance.openingHours,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'notes': instance.notes,
      'isFavorite': instance.isFavorite,
      'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
    };

VeterinarianModel _$VeterinarianModelFromJson(Map<String, dynamic> json) =>
    VeterinarianModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      clinicId: json['clinicId'] as String?,
      specialization: json['specialization'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
      updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$VeterinarianModelToJson(VeterinarianModel instance) =>
    <String, dynamic>{
      'ownerId': instance.ownerId,
      'name': instance.name,
      'clinicId': instance.clinicId,
      'specialization': instance.specialization,
      'phone': instance.phone,
      'email': instance.email,
      'notes': instance.notes,
      'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
    };
