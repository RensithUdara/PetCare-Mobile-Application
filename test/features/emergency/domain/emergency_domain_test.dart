import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/emergency/data/models/emergency_models.dart';
import 'package:petcare/features/emergency/domain/entities/emergency_profile.dart';
import 'package:petcare/features/emergency/domain/logic/public_profile.dart';
import 'package:petcare/features/emergency/domain/usecases/emergency_usecases.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';

import '../../../helpers/fake_emergency_repository.dart';

void main() {
  const bruno = Pet(
    id: 'bruno',
    ownerId: 'u1',
    name: 'Bruno',
    species: PetSpecies.dog,
    breed: 'Golden Retriever',
    microchipId: '985112004455667',
    photoUrl: 'https://firebasestorage.googleapis.com/bruno.jpg',
    notes: 'Private vet notes',
  );

  const settings = EmergencyProfile(
    petId: 'bruno',
    ownerId: 'u1',
    publicId: 'PC-8A72F9K',
    contactName: 'Kasun',
    contactPhone: '077 123 4567',
    medicalWarnings: '  ',
  );

  group('public IDs', () {
    test('format and alphabet', () {
      final id = generatePublicId(Random(1));
      expect(id, matches(RegExp(r'^PC-[23456789A-HJKMNP-Z]{7}$')));
      expect(isValidPublicId(id), isTrue);
      expect(isValidPublicId('PC-0OIL123'), isFalse, reason: 'ambiguous characters');
      expect(isValidPublicId('../users'), isFalse);
    });
  });

  group('buildPublicProfile (privacy gate)', () {
    test('shares only what settings allow and never private fields', () {
      final p = buildPublicProfile(bruno, settings);
      expect(p.petName, 'Bruno');
      expect(p.species, 'dog');
      expect(p.breed, 'Golden Retriever');
      expect(p.photoUrl, bruno.photoUrl);
      expect(p.microchipId, isNull, reason: 'microchip hidden by default');
      expect(p.medicalWarnings, isNull, reason: 'blank text is dropped');
      expect(p.ownerId, 'u1');
    });

    test('toggles hide photo and breed, show microchip', () {
      final p = buildPublicProfile(
        bruno,
        settings.copyWith(showPhoto: false, showBreed: false, showMicrochip: true),
      );
      expect(p.photoUrl, isNull);
      expect(p.breed, isNull);
      expect(p.microchipId, '985112004455667');
    });

    test('public JSON never contains private pet data', () {
      final json = PublicPetProfileModel.fromEntity(buildPublicProfile(bruno, settings)).toJson();
      expect(json.keys, isNot(contains('notes')));
      expect(json.values, isNot(contains('Private vet notes')));
      expect(json.containsKey('microchipId'), isFalse, reason: 'nulls omitted');
    });
  });

  group('use cases', () {
    late FakeEmergencyRepository repo;
    late SaveEmergencyProfile save;

    setUp(() {
      repo = FakeEmergencyRepository();
      save = SaveEmergencyProfile(repo);
    });

    test('create picks an unused id, saves settings and publishes', () async {
      // Force a collision on the first attempt.
      final taken = generatePublicId(Random(7));
      repo = FakeEmergencyRepository(takenIds: {taken});
      save = SaveEmergencyProfile(repo);

      final created = await CreateEmergencyProfile(repo, save, Random(7))(
        ownerId: 'u1',
        pet: bruno,
        contactPhone: '0771234567',
        contactName: 'Kasun',
      );

      expect(created.publicId, isNot(taken));
      expect(created.showMicrochip, isTrue, reason: 'pet has a microchip');
      expect(repo.settingsFor('bruno'), created);
      expect(repo.public[created.publicId]?.contactPhone, '0771234567');
    });

    test('enabled profile requires a valid phone', () {
      expect(save(pet: bruno, settings: settings.copyWith(contactPhone: ' ')),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'missing-phone')));
      expect(save(pet: bruno, settings: settings.copyWith(contactPhone: 'call me')),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-phone')));
    });

    test('disabling withdraws the page but keeps the id', () async {
      await save(pet: bruno, settings: settings);
      expect(repo.public, contains('PC-8A72F9K'));

      await save(pet: bruno, settings: settings.copyWith(enabled: false, contactPhone: null));
      expect(repo.public, isEmpty);
      expect(repo.settingsFor('bruno')?.publicId, 'PC-8A72F9K');
    });

    test('refresh republishes pet changes only when enabled', () async {
      repo = FakeEmergencyRepository(settings: [settings]);
      await RefreshPublicProfile(repo)(ownerId: 'u1', pet: bruno.copyWith(name: 'Bruno II'));
      expect(repo.public['PC-8A72F9K']?.petName, 'Bruno II');

      repo = FakeEmergencyRepository(settings: [settings.copyWith(enabled: false)]);
      await RefreshPublicProfile(repo)(ownerId: 'u1', pet: bruno);
      expect(repo.public, isEmpty);
    });

    test('watching an invalid id never hits the repository', () async {
      expect(await WatchPublicProfile(repo)('not-an-id').first, isNull);
    });
  });

  test('EmergencyProfileModel round-trips', () {
    final json = EmergencyProfileModel.fromEntity(settings).toJson();
    expect(EmergencyProfileModel.fromJson(json).toEntity(), settings);
  });
}
