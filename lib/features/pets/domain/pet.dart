// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/json_converters.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

enum PetSpecies {
  dog('Dog', '🐶'),
  cat('Cat', '🐱'),
  bird('Bird', '🐦'),
  rabbit('Rabbit', '🐰'),
  other('Other', '🐾');

  const PetSpecies(this.label, this.emoji);
  final String label;
  final String emoji;
}

enum PetGender {
  male('Male'),
  female('Female'),
  unknown('Unknown');

  const PetGender(this.label);
  final String label;
}

@freezed
abstract class Pet with _$Pet {
  const Pet._();

  const factory Pet({
    /// Firestore document id; not stored inside the document itself.
    @JsonKey(includeToJson: false) @Default('') String id,
    required String ownerId,
    required String name,
    @JsonKey(unknownEnumValue: PetSpecies.other) required PetSpecies species,
    String? breed,
    @JsonKey(unknownEnumValue: PetGender.unknown)
    @Default(PetGender.unknown)
    PetGender gender,
    @NullableDateTimeConverter() DateTime? dateOfBirth,
    double? weightKg,
    String? color,
    String? microchipId,
    String? registrationNumber,
    String? notes,
    String? photoUrl,
    @NullableDateTimeConverter() DateTime? createdAt,
    @NullableDateTimeConverter() DateTime? updatedAt,
  }) = _Pet;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

  /// e.g. "Golden Retriever" or "Dog" when no breed is set.
  String get breedOrSpecies =>
      (breed == null || breed!.trim().isEmpty) ? species.label : breed!;
}
