import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/domain/logic/pet_age.dart';

void main() {
  test('breedOrSpecies falls back to species label', () {
    const pet = Pet(ownerId: 'u', name: 'Kiwi', species: PetSpecies.bird, breed: '  ');
    expect(pet.breedOrSpecies, 'Bird');
    expect(pet.copyWith(breed: 'Budgie').breedOrSpecies, 'Budgie');
  });

  test('isNew is true until an id is assigned', () {
    const pet = Pet(ownerId: 'u', name: 'Kiwi', species: PetSpecies.bird);
    expect(pet.isNew, isTrue);
    expect(pet.copyWith(id: 'p1').isNew, isFalse);
  });

  group('petAgeLabel', () {
    final now = DateTime(2026, 9, 26);

    test('years, months, weeks and days', () {
      expect(petAgeLabel(DateTime(2023, 3, 15), now), '3 years old');
      expect(petAgeLabel(DateTime(2025, 9, 26), now), '1 year old');
      expect(petAgeLabel(DateTime(2025, 9, 27), now), '11 months old');
      expect(petAgeLabel(DateTime(2026, 8, 26), now), '1 month old');
      expect(petAgeLabel(DateTime(2026, 9, 5), now), '3 weeks old');
      expect(petAgeLabel(DateTime(2026, 9, 25), now), '1 day old');
      expect(petAgeLabel(DateTime(2026, 9, 26), now), 'Born today');
    });

    test('null for unknown or future dates', () {
      expect(petAgeLabel(null, now), isNull);
      expect(petAgeLabel(DateTime(2026, 10, 1), now), isNull);
    });
  });
}
