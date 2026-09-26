import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/emergency/domain/entities/emergency_profile.dart';
import 'package:petcare/features/emergency/presentation/providers/emergency_providers.dart';
import 'package:petcare/features/emergency/presentation/screens/emergency_profile_screen.dart';
import 'package:petcare/features/emergency/presentation/screens/public_profile_screen.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../helpers/fake_emergency_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  const bruno = Pet(
    id: 'bruno',
    ownerId: 'u1',
    name: 'Bruno',
    species: PetSpecies.dog,
    breed: 'Golden Retriever',
    microchipId: '985112004455667',
  );

  Future<void> pump(WidgetTester tester, FakeEmergencyRepository repo, Widget screen, {String? uid = 'u1'}) =>
      pumpScreen(tester, screen, physicalSize: const Size(1080, 4400), overrides: [
        currentUserIdProvider.overrideWithValue(uid),
        petRepositoryProvider.overrideWithValue(FakePetRepository(const [bruno])),
        emergencyProfileRepositoryProvider.overrideWithValue(repo),
        publicProfileBaseUrlProvider.overrideWithValue('https://petcare-test.web.app/p/'),
      ]);

  testWidgets('owner creates a QR Pet ID', (tester) async {
    final repo = FakeEmergencyRepository();
    await pump(tester, repo, const EmergencyProfileScreen(petId: 'bruno'));

    expect(find.text('Help Bruno get home'), findsOneWidget);
    await tester.tap(find.text('Create QR Pet ID'));
    await tester.pump();
    expect(find.text('A phone number is required'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Emergency phone *'), '0771234567');
    await tester.tap(find.text('Create QR Pet ID'));
    await tester.pumpAndSettle();

    final settings = repo.settingsFor('bruno')!;
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text(settings.publicId), findsOneWidget);
    expect(find.text('Public profile is on'), findsOneWidget);
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, contains('Bruno'));
    expect(repo.public[settings.publicId]?.contactPhone, '0771234567');
  });

  testWidgets('owner changes what is public and republishes', (tester) async {
    final repo = FakeEmergencyRepository(settings: const [
      EmergencyProfile(petId: 'bruno', ownerId: 'u1', publicId: 'PC-8A72F9K', contactPhone: '0771234567'),
    ]);
    await pump(tester, repo, const EmergencyProfileScreen(petId: 'bruno'));

    expect(find.text('No photo on the pet profile'), findsOneWidget);
    await tester.tap(find.text('Microchip ID'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Medical warnings'), 'Diabetic');
    await tester.tap(find.text('Save & Publish'));
    await tester.pumpAndSettle();

    final page = repo.public['PC-8A72F9K']!;
    expect(page.microchipId, '985112004455667');
    expect(page.medicalWarnings, 'Diabetic');
    expect(find.text('Emergency profile updated'), findsOneWidget);
  });

  group('PublicProfileScreen', () {
    testWidgets('shows shared details to a signed-out finder', (tester) async {
      final repo = FakeEmergencyRepository()
        ..public['PC-8A72F9K'] = const PublicPetProfile(
          publicId: 'PC-8A72F9K',
          ownerId: 'u1',
          petName: 'Bruno',
          species: 'dog',
          breed: 'Golden Retriever',
          contactName: 'Kasun',
          contactPhone: '077 123 4567',
          medicalWarnings: 'Diabetic — needs insulin',
        );
      await pump(tester, repo, const PublicProfileScreen(publicId: 'PC-8A72F9K'), uid: null);

      expect(find.text('BRUNO'), findsOneWidget);
      expect(find.text('Golden Retriever'), findsOneWidget);
      expect(find.text('Call Kasun'), findsOneWidget);
      expect(find.text('Diabetic — needs insulin'), findsOneWidget);
      expect(find.text('Microchip ID'), findsNothing);
    });

    testWidgets('unknown or disabled profile', (tester) async {
      await pump(tester, FakeEmergencyRepository(), const PublicProfileScreen(publicId: 'PC-ZZZZZZZ'),
          uid: null);
      expect(find.text('Profile not available'), findsOneWidget);
    });
  });
}
