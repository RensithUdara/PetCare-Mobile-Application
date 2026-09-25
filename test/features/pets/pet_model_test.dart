import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/pets/domain/pet.dart';
import 'package:petcare/features/pets/domain/pet_age.dart';

void main() {
  group('Pet JSON', () {
    final bruno = Pet(
      id: 'p1',
      ownerId: 'u1',
      name: 'Bruno',
      species: PetSpecies.dog,
      breed: 'Golden Retriever',
      gender: PetGender.male,
      dateOfBirth: DateTime(2023, 3, 15),
      weightKg: 12.5,
    );

    test('round-trips and does not store the id inside the document', () {
      final json = bruno.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['species'], 'dog');
      expect(json['dateOfBirth'], DateTime(2023, 3, 15));

      final restored = Pet.fromJson({...json, 'id': 'p1'});
      expect(restored, bruno);
    });

    test('accepts integer weights and ISO date strings', () {
      final pet = Pet.fromJson({
        'id': 'p2',
        'ownerId': 'u1',
        'name': 'Milo',
        'species': 'cat',
        'weightKg': 4,
        'dateOfBirth': '2024-01-10T00:00:00.000',
      });
      expect(pet.weightKg, 4.0);
      expect(pet.dateOfBirth, DateTime(2024, 1, 10));
      expect(pet.gender, PetGender.unknown);
    });

    test('unknown species falls back to other', () {
      final pet = Pet.fromJson({'ownerId': 'u1', 'name': 'Rex', 'species': 'dinosaur'});
      expect(pet.species, PetSpecies.other);
    });
  });

  test('breedOrSpecies falls back to species label', () {
    const pet = Pet(ownerId: 'u', name: 'Kiwi', species: PetSpecies.bird, breed: '  ');
    expect(pet.breedOrSpecies, 'Bird');
    expect(pet.copyWith(breed: 'Budgie').breedOrSpecies, 'Budgie');
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
