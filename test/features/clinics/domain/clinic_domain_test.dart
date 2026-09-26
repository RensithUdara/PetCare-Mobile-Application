import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/clinics/domain/entities/clinic.dart';
import 'package:petcare/features/clinics/domain/logic/geo.dart';
import 'package:petcare/features/clinics/domain/usecases/clinic_usecases.dart';
import 'package:petcare/features/clinics/domain/usecases/nearby_usecases.dart';

import '../../../helpers/fake_clinic_repositories.dart';

void main() {
  const colombo = GeoPoint(6.9271, 79.8612);
  const kandy = GeoPoint(7.2906, 80.6337);

  group('geo', () {
    test('distanceMeters (Colombo → Kandy ≈ 94 km)', () {
      expect(distanceMeters(colombo, kandy), closeTo(94000, 2000));
      expect(distanceMeters(colombo, colombo), 0);
    });

    test('formatDistance', () {
      expect(formatDistance(847), '850 m');
      expect(formatDistance(2430), '2.4 km');
      expect(formatDistance(12600), '13 km');
    });

    test('normalizeWebsite', () {
      expect(normalizeWebsite('happypaws.lk'), 'https://happypaws.lk');
      expect(normalizeWebsite('HTTP://x.lk'), 'HTTP://x.lk');
      expect(normalizeWebsite('  '), isNull);
    });
  });

  group('SaveClinic', () {
    test('normalises fields', () async {
      final repo = FakeClinicRepository();
      final id = await SaveClinic(repo)(
        ownerId: 'u1',
        clinic: const Clinic(
          ownerId: '',
          name: '  Happy Paws ',
          website: 'happypaws.lk',
          phone: ' 011 234 5678 ',
          email: '',
        ),
      );

      final saved = repo.clinics.single;
      expect(saved.id, id);
      expect(saved.name, 'Happy Paws');
      expect(saved.website, 'https://happypaws.lk');
      expect(saved.phone, '011 234 5678');
      expect(saved.email, isNull);
    });

    test('validates name and email', () {
      final save = SaveClinic(FakeClinicRepository());
      expect(save(ownerId: 'u1', clinic: const Clinic(ownerId: '', name: ' ')),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-name')));
      expect(save(ownerId: 'u1', clinic: const Clinic(ownerId: '', name: 'A', email: 'nope')),
          throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-email')));
    });
  });

  test('WatchClinics puts favourites first, then by name', () async {
    final repo = FakeClinicRepository(clinics: const [
      Clinic(id: '1', ownerId: 'u1', name: 'zoo vets'),
      Clinic(id: '2', ownerId: 'u1', name: 'Animal Care'),
      Clinic(id: '3', ownerId: 'u1', name: 'Pet Plus', isFavorite: true),
    ]);
    final list = await WatchClinics(repo)('u1').first;
    expect(list.map((c) => c.id), ['3', '2', '1']);
  });

  test('DeleteClinic keeps its vets but unlinks them', () async {
    final repo = FakeClinicRepository(
      clinics: const [Clinic(id: 'c1', ownerId: 'u1', name: 'Happy Paws')],
      vets: const [
        Veterinarian(id: 'v1', ownerId: 'u1', name: 'Dr. Silva', clinicId: 'c1'),
        Veterinarian(id: 'v2', ownerId: 'u1', name: 'Dr. Perera', clinicId: 'other'),
      ],
    );

    await DeleteClinic(repo)(ownerId: 'u1', clinicId: 'c1');

    expect(repo.clinics, isEmpty);
    expect(repo.vets.map((v) => (v.id, v.clinicId)), [('v1', null), ('v2', 'other')]);
  });

  test('SaveVet validates and trims', () async {
    final repo = FakeClinicRepository();
    await SaveVet(repo)(
      ownerId: 'u1',
      vet: const Veterinarian(ownerId: '', name: ' Dr. Kasun Silva ', specialization: ' '),
    );
    expect(repo.vets.single.name, 'Dr. Kasun Silva');
    expect(repo.vets.single.specialization, isNull);

    expect(SaveVet(repo)(ownerId: 'u1', vet: const Veterinarian(ownerId: '', name: '')),
        throwsA(isA<Failure>()));
  });

  test('SearchNearbyClinics adds distances, sorts and normalises', () async {
    NearbyClinic at(String name, GeoPoint p, {String? website}) => NearbyClinic(
        externalId: name, name: name, location: p, distanceMeters: 0, website: website);
    final nearby = FakeNearbyClinicsRepository([
      at('Far', const GeoPoint(6.95, 79.90), website: 'far.lk'),
      at('Near', const GeoPoint(6.928, 79.862)),
    ]);

    final results = await SearchNearbyClinics(nearby)(colombo);

    expect(results.map((c) => c.name), ['Near', 'Far']);
    expect(results.first.distanceMeters, lessThan(200));
    expect(results.last.website, 'https://far.lk');
    expect(nearby.lastCenter, colombo);
  });
}
