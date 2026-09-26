import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/pets/data/models/pet_model.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';

void main() {
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

  test('entity → model → JSON → model → entity round-trips', () {
    final json = PetModel.fromEntity(bruno).toJson();

    expect(json.containsKey('id'), isFalse, reason: 'id is the document id');
    expect(json['species'], 'dog');
    expect(json['gender'], 'male');
    expect(json['dateOfBirth'], DateTime(2023, 3, 15));

    expect(PetModel.fromJson({...json, 'id': 'p1'}).toEntity(), bruno);
  });

  test('accepts integer weights and ISO date strings', () {
    final pet = PetModel.fromJson({
      'id': 'p2',
      'ownerId': 'u1',
      'name': 'Milo',
      'species': 'cat',
      'weightKg': 4,
      'dateOfBirth': '2024-01-10T00:00:00.000',
    }).toEntity();

    expect(pet.weightKg, 4.0);
    expect(pet.dateOfBirth, DateTime(2024, 1, 10));
    expect(pet.gender, PetGender.unknown);
  });

  test('unknown enum values fall back safely', () {
    final pet = PetModel.fromJson({
      'ownerId': 'u1',
      'name': 'Rex',
      'species': 'dinosaur',
      'gender': '???',
    }).toEntity();

    expect(pet.species, PetSpecies.other);
    expect(pet.gender, PetGender.unknown);
  });
}
