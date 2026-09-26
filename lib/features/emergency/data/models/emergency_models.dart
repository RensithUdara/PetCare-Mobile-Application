import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/emergency_profile.dart';

part 'emergency_models.g.dart';

/// `users/{uid}/emergencyProfiles/{petId}` (private).
@JsonSerializable(includeIfNull: true)
class EmergencyProfileModel {
  const EmergencyProfileModel({
    required this.petId,
    required this.ownerId,
    required this.publicId,
    this.enabled = true,
    this.showPhoto = true,
    this.showBreed = true,
    this.showMicrochip = false,
    this.contactName,
    this.contactPhone,
    this.medicalWarnings,
    this.message,
    this.updatedAt,
  });

  factory EmergencyProfileModel.fromJson(Map<String, dynamic> json) =>
      _$EmergencyProfileModelFromJson(json);

  factory EmergencyProfileModel.fromEntity(EmergencyProfile e) => EmergencyProfileModel(
        petId: e.petId,
        ownerId: e.ownerId,
        publicId: e.publicId,
        enabled: e.enabled,
        showPhoto: e.showPhoto,
        showBreed: e.showBreed,
        showMicrochip: e.showMicrochip,
        contactName: e.contactName,
        contactPhone: e.contactPhone,
        medicalWarnings: e.medicalWarnings,
        message: e.message,
      );

  final String petId;
  final String ownerId;
  final String publicId;
  final bool enabled;
  final bool showPhoto;
  final bool showBreed;
  final bool showMicrochip;
  final String? contactName;
  final String? contactPhone;
  final String? medicalWarnings;
  final String? message;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$EmergencyProfileModelToJson(this);

  EmergencyProfile toEntity() => EmergencyProfile(
        petId: petId,
        ownerId: ownerId,
        publicId: publicId,
        enabled: enabled,
        showPhoto: showPhoto,
        showBreed: showBreed,
        showMicrochip: showMicrochip,
        contactName: contactName,
        contactPhone: contactPhone,
        medicalWarnings: medicalWarnings,
        message: message,
        updatedAt: updatedAt,
      );
}

/// `publicProfiles/{publicId}` (world-readable). Also read by the hosted
/// web page `public/p.html` — keep field names in sync.
@JsonSerializable(includeIfNull: false)
class PublicPetProfileModel {
  const PublicPetProfileModel({
    required this.publicId,
    required this.ownerId,
    required this.petName,
    required this.species,
    this.breed,
    this.photoUrl,
    this.microchipId,
    this.contactName,
    this.contactPhone,
    this.medicalWarnings,
    this.message,
    this.updatedAt,
  });

  factory PublicPetProfileModel.fromJson(Map<String, dynamic> json) =>
      _$PublicPetProfileModelFromJson(json);

  factory PublicPetProfileModel.fromEntity(PublicPetProfile p) => PublicPetProfileModel(
        publicId: p.publicId,
        ownerId: p.ownerId,
        petName: p.petName,
        species: p.species,
        breed: p.breed,
        photoUrl: p.photoUrl,
        microchipId: p.microchipId,
        contactName: p.contactName,
        contactPhone: p.contactPhone,
        medicalWarnings: p.medicalWarnings,
        message: p.message,
      );

  final String publicId;
  final String ownerId;
  final String petName;
  final String species;
  final String? breed;
  final String? photoUrl;
  final String? microchipId;
  final String? contactName;
  final String? contactPhone;
  final String? medicalWarnings;
  final String? message;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$PublicPetProfileModelToJson(this);

  PublicPetProfile toEntity() => PublicPetProfile(
        publicId: publicId,
        ownerId: ownerId,
        petName: petName,
        species: species,
        breed: breed,
        photoUrl: photoUrl,
        microchipId: microchipId,
        contactName: contactName,
        contactPhone: contactPhone,
        medicalWarnings: medicalWarnings,
        message: message,
        updatedAt: updatedAt,
      );
}
