import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet.freezed.dart';

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

/// A pet owned by the signed-in user. Pure domain entity: no JSON or
/// Firebase concerns (see `PetModel` in the data layer).
@freezed
abstract class Pet with _$Pet {
  const Pet._();

  const factory Pet({
    /// Empty for a pet that has not been saved yet.
    @Default('') String id,
    required String ownerId,
    required String name,
    required PetSpecies species,
    String? breed,
    @Default(PetGender.unknown) PetGender gender,
    DateTime? dateOfBirth,
    double? weightKg,
    String? color,
    String? microchipId,
    String? registrationNumber,
    String? notes,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Pet;

  bool get isNew => id.isEmpty;

  /// e.g. "Golden Retriever" or "Dog" when no breed is set.
  String get breedOrSpecies =>
      (breed == null || breed!.trim().isEmpty) ? species.label : breed!;
}
