import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/clinic.dart';

part 'clinic_models.g.dart';

/// Firestore representation of a [Clinic] (`users/{uid}/clinics/{id}`).
@JsonSerializable(includeIfNull: true)
class ClinicModel {
  const ClinicModel({
    this.id = '',
    required this.ownerId,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.openingHours,
    this.latitude,
    this.longitude,
    this.notes,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) => _$ClinicModelFromJson(json);

  factory ClinicModel.fromEntity(Clinic c) => ClinicModel(
        id: c.id,
        ownerId: c.ownerId,
        name: c.name,
        address: c.address,
        phone: c.phone,
        email: c.email,
        website: c.website,
        openingHours: c.openingHours,
        latitude: c.location?.latitude,
        longitude: c.location?.longitude,
        notes: c.notes,
        isFavorite: c.isFavorite,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
      );

  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? openingHours;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final bool isFavorite;
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$ClinicModelToJson(this);

  Clinic toEntity() => Clinic(
        id: id,
        ownerId: ownerId,
        name: name,
        address: address,
        phone: phone,
        email: email,
        website: website,
        openingHours: openingHours,
        location: (latitude != null && longitude != null) ? GeoPoint(latitude!, longitude!) : null,
        notes: notes,
        isFavorite: isFavorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// Firestore representation of a [Veterinarian]
/// (`users/{uid}/veterinarians/{id}`).
@JsonSerializable(includeIfNull: true)
class VeterinarianModel {
  const VeterinarianModel({
    this.id = '',
    required this.ownerId,
    required this.name,
    this.clinicId,
    this.specialization,
    this.phone,
    this.email,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory VeterinarianModel.fromJson(Map<String, dynamic> json) =>
      _$VeterinarianModelFromJson(json);

  factory VeterinarianModel.fromEntity(Veterinarian v) => VeterinarianModel(
        id: v.id,
        ownerId: v.ownerId,
        name: v.name,
        clinicId: v.clinicId,
        specialization: v.specialization,
        phone: v.phone,
        email: v.email,
        notes: v.notes,
        createdAt: v.createdAt,
        updatedAt: v.updatedAt,
      );

  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String name;
  final String? clinicId;
  final String? specialization;
  final String? phone;
  final String? email;
  final String? notes;
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$VeterinarianModelToJson(this);

  Veterinarian toEntity() => Veterinarian(
        id: id,
        ownerId: ownerId,
        name: name,
        clinicId: clinicId,
        specialization: specialization,
        phone: phone,
        email: email,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
