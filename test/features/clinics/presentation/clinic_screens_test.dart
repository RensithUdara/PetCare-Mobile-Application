import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/clinics/domain/entities/clinic.dart';
import 'package:petcare/features/clinics/presentation/providers/clinic_providers.dart';
import 'package:petcare/features/clinics/presentation/screens/clinic_details_screen.dart';
import 'package:petcare/features/clinics/presentation/screens/clinic_form_screen.dart';
import 'package:petcare/features/clinics/presentation/screens/clinics_map_screen.dart';
import 'package:petcare/features/clinics/presentation/screens/clinics_screen.dart';
import 'package:petcare/features/clinics/presentation/screens/vet_form_screen.dart';

import '../../../helpers/fake_clinic_repositories.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  const happyPaws = Clinic(
    id: 'c1',
    ownerId: 'u1',
    name: 'Happy Paws Veterinary Clinic',
    address: '12 Galle Road, Colombo',
    phone: '0112345678',
    website: 'https://happypaws.lk',
    location: GeoPoint(6.91, 79.85),
    isFavorite: true,
  );
  const silva = Veterinarian(
    id: 'v1',
    ownerId: 'u1',
    name: 'Dr. Kasun Silva',
    clinicId: 'c1',
    specialization: 'General Veterinary Medicine',
  );

  Future<void> pump(WidgetTester tester, FakeClinicRepository repo, Widget screen,
          {FakeNearbyClinicsRepository? nearby}) =>
      pumpScreen(tester, screen, physicalSize: const Size(1080, 3200), overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        clinicRepositoryProvider.overrideWithValue(repo),
        nearbyClinicsRepositoryProvider.overrideWithValue(nearby ?? FakeNearbyClinicsRepository([])),
        locationRepositoryProvider.overrideWithValue(FakeLocationRepository()),
        mapTileUrlProvider.overrideWithValue(null), // no network tiles in tests
      ]);

  testWidgets('clinics list, vet counts, search and vets tab', (tester) async {
    final repo = FakeClinicRepository(
      clinics: const [happyPaws, Clinic(id: 'c2', ownerId: 'u1', name: 'City Pet Hospital')],
      vets: const [silva],
    );
    await pump(tester, repo, const ClinicsScreen());

    expect(find.text('Clinics (2)'), findsOneWidget);
    expect(find.textContaining('1 vet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'city');
    await tester.pump();
    expect(find.text('Happy Paws Veterinary Clinic'), findsNothing);
    expect(find.text('City Pet Hospital'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Veterinarians (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Kasun Silva'), findsOneWidget);
    expect(find.textContaining('Happy Paws Veterinary Clinic'), findsOneWidget);
    expect(find.text('Add Vet'), findsOneWidget);
  });

  testWidgets('clinic form normalises and saves', (tester) async {
    final repo = FakeClinicRepository();
    await pump(tester, repo, const ClinicFormScreen());

    await tester.enterText(find.widgetWithText(TextFormField, 'Clinic name *'), 'Pet Plus');
    await tester.enterText(find.widgetWithText(TextFormField, 'Website'), 'petplus.lk');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'bad');
    await tester.tap(find.text('Save Clinic'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), '');
    await tester.tap(find.text('Save Clinic'));
    await tester.pumpAndSettle();

    expect(repo.clinics.single.name, 'Pet Plus');
    expect(repo.clinics.single.website, 'https://petplus.lk');
    expect(find.text('previous page'), findsOneWidget);
  });

  testWidgets('clinic details: contact actions, vets, favourite toggle', (tester) async {
    final repo = FakeClinicRepository(clinics: const [happyPaws], vets: const [silva]);
    await pump(tester, repo, const ClinicDetailsScreen(clinicId: 'c1'));

    for (final action in ['Call', 'Website', 'Directions']) {
      expect(find.byTooltip(action), findsOneWidget, reason: action);
    }
    expect(find.byTooltip('Email'), findsNothing);
    expect(find.text('Dr. Kasun Silva'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from favourites'));
    await tester.pumpAndSettle();
    expect(repo.clinics.single.isFavorite, isFalse);
  });

  testWidgets('vet form links the vet to a clinic', (tester) async {
    final repo = FakeClinicRepository(clinics: const [happyPaws]);
    await pump(tester, repo, const VetFormScreen(clinicId: 'c1'));

    await tester.enterText(find.widgetWithText(TextFormField, 'Dr. '), 'Dr. Nimali Perera');
    await tester.tap(find.text('Save Veterinarian'));
    await tester.pumpAndSettle();

    expect(repo.vets.single.name, 'Dr. Nimali Perera');
    expect(repo.vets.single.clinicId, 'c1');
  });

  testWidgets('map: find nearby vets and save one', (tester) async {
    final repo = FakeClinicRepository();
    final nearby = FakeNearbyClinicsRepository(const [
      NearbyClinic(
        externalId: 'osm:node/1',
        name: 'Paws & Claws',
        location: GeoPoint(6.93, 79.862),
        distanceMeters: 0,
        address: 'Marine Drive',
      ),
    ]);
    await pump(tester, repo, const ClinicsMapScreen(), nearby: nearby);

    await tester.tap(find.text('Find vets near me'));
    await tester.pumpAndSettle();
    expect(find.text('Paws & Claws'), findsOneWidget);
    expect(find.textContaining('Marine Drive'), findsOneWidget);

    await tester.tap(find.text('Paws & Claws'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save to my clinics'));
    await tester.pumpAndSettle();

    expect(repo.clinics.single.name, 'Paws & Claws');
    expect(repo.clinics.single.location, const GeoPoint(6.93, 79.862));
  });
}
