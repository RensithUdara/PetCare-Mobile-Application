import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/pet.dart';

part 'pet_model.g.dart';

/// Firestore representation of a [Pet] (`users/{uid}/pets/{petId}`).
@JsonSerializable(includeIfNull: true)
class PetModel {
  const PetModel({
    this.id = '',
    required this.ownerId,
    required this.name,
    required this.species,
    this.breed,
    this.gender,
    this.dateOfBirth,
    this.weightKg,
    this.color,
    this.microchipId,
    this.registrationNumber,
    this.notes,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) => _$PetModelFromJson(json);

  factory PetModel.fromEntity(Pet pet) => PetModel(
        id: pet.id,
        ownerId: pet.ownerId,
        name: pet.name,
        species: pet.species.name,
        breed: pet.breed,
        gender: pet.gender.name,
        dateOfBirth: pet.dateOfBirth,
        weightKg: pet.weightKg,
        color: pet.color,
        microchipId: pet.microchipId,
        registrationNumber: pet.registrationNumber,
        notes: pet.notes,
        photoUrl: pet.photoUrl,
        createdAt: pet.createdAt,
        updatedAt: pet.updatedAt,
      );

  /// Document id; not stored inside the document.
  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String? breed;
  final String? gender;
  @NullableDateTimeConverter()
  final DateTime? dateOfBirth;
  final double? weightKg;
  final String? color;
  final String? microchipId;
  final String? registrationNumber;
  final String? notes;
  final String? photoUrl;
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$PetModelToJson(this);

  Pet toEntity() => Pet(
        id: id,
        ownerId: ownerId,
        name: name,
        species: PetSpecies.values.asNameMap()[species] ?? PetSpecies.other,
        breed: breed,
        gender: PetGender.values.asNameMap()[gender] ?? PetGender.unknown,
        dateOfBirth: dateOfBirth,
        weightKg: weightKg,
        color: color,
        microchipId: microchipId,
        registrationNumber: registrationNumber,
        notes: notes,
        photoUrl: photoUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
