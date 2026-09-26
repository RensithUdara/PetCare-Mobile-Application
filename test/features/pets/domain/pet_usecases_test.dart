import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/domain/entities/photo_change.dart';
import 'package:petcare/features/pets/domain/usecases/delete_pet.dart';
import 'package:petcare/features/pets/domain/usecases/save_pet.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';

import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_vaccination_repository.dart';

void main() {
  const draft = Pet(ownerId: '', name: 'Bruno', species: PetSpecies.dog);
  const existing = Pet(
    id: 'p1',
    ownerId: 'u1',
    name: 'Bruno',
    species: PetSpecies.dog,
    photoUrl: 'https://photos/old.jpg',
  );

  group('SavePet', () {
    late FakePetRepository repo;
    late SavePet savePet;

    setUp(() {
      repo = FakePetRepository([existing]);
      savePet = SavePet(repo);
    });

    test('new pet gets an id and the given owner', () async {
      final id = await savePet(ownerId: 'u1', pet: draft);

      expect(id, 'pet1');
      final saved = repo.pets.firstWhere((p) => p.id == id);
      expect(saved.ownerId, 'u1');
      expect(saved.photoUrl, isNull);
    });

    test('new photo is uploaded before saving and reports progress', () async {
      final progress = <double>[];
      final id = await savePet(
        ownerId: 'u1',
        pet: draft,
        photo: PhotoReplaced(Uint8List.fromList([1, 2, 3])),
        onUploadProgress: progress.add,
      );

      expect(repo.calls, ['upload:$id:3', 'save:$id']);
      expect(repo.pets.firstWhere((p) => p.id == id).photoUrl, startsWith('https://photos/$id/'));
      expect(progress, [0.5, 1.0]);
    });

    test('replacing a photo deletes the old file after saving', () async {
      await savePet(ownerId: 'u1', pet: existing, photo: PhotoReplaced(Uint8List(4)));

      expect(repo.pets.single.photoUrl, isNot(existing.photoUrl));
      expect(repo.deletedPhotos, [existing.photoUrl]);
    });

    test('removing a photo clears the url and deletes the file', () async {
      await savePet(ownerId: 'u1', pet: existing, photo: const PhotoRemoved());

      expect(repo.pets.single.photoUrl, isNull);
      expect(repo.deletedPhotos, [existing.photoUrl]);
    });

    test('unchanged photo is kept and nothing is deleted', () async {
      await savePet(ownerId: 'u1', pet: existing.copyWith(name: 'Bruno II'));

      expect(repo.pets.single.name, 'Bruno II');
      expect(repo.pets.single.photoUrl, existing.photoUrl);
      expect(repo.deletedPhotos, isEmpty);
    });

    test('a failed save keeps the old photo', () async {
      repo.saveFailure = const Failure('Could not save pet.');

      await expectLater(
        savePet(ownerId: 'u1', pet: existing, photo: PhotoReplaced(Uint8List(1))),
        throwsA(isA<Failure>()),
      );
      expect(repo.deletedPhotos, isEmpty);
    });
  });

  group('DeletePet', () {
    test('removes the pet and its vaccinations', () async {
      final pets = FakePetRepository([existing]);
      final vaccinations = FakeVaccinationRepository([
        Vaccination(
          id: 'v1',
          ownerId: 'u1',
          petId: 'p1',
          vaccineName: 'Rabies',
          dateAdministered: DateTime(2025),
        ),
        Vaccination(
          id: 'v2',
          ownerId: 'u1',
          petId: 'other',
          vaccineName: 'Rabies',
          dateAdministered: DateTime(2025),
        ),
      ]);

      await DeletePet(pets, [vaccinations])(ownerId: 'u1', petId: 'p1');

      expect(pets.pets, isEmpty);
      expect(vaccinations.items.map((v) => v.id), ['v2']);
      expect(vaccinations.calls, ['deleteAllForPet:p1']);
    });
  });
}
