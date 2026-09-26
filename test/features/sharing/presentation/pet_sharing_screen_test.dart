import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/profile/domain/entities/user_profile.dart';
import 'package:petcare/features/profile/presentation/providers/profile_providers.dart';
import 'package:petcare/features/sharing/domain/entities/doctor_profile.dart';
import 'package:petcare/features/sharing/domain/entities/pet_share.dart';
import 'package:petcare/features/sharing/presentation/providers/sharing_providers.dart';
import 'package:petcare/features/sharing/presentation/screens/pet_sharing_screen.dart';

import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_sharing_repository.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  const bruno = Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog);
  const nimali = DoctorProfile(
    id: 'doc1',
    fullName: 'Dr. Nimali Perera',
    doctorCode: 'DR-7K3M9Q',
    clinicName: 'Happy Paws',
  );

  Future<void> pump(WidgetTester tester, FakeSharingRepository repo) => pumpScreen(
        tester,
        const PetSharingScreen(petId: 'bruno'),
        physicalSize: const Size(1080, 3600),
        overrides: [
          currentUserIdProvider.overrideWithValue('u1'),
          petRepositoryProvider.overrideWithValue(FakePetRepository(const [bruno])),
          sharingRepositoryProvider.overrideWithValue(repo),
          userProfileProvider.overrideWith((ref) => Stream.value(
                const UserProfile(id: 'u1', fullName: 'Kasun Silva', email: 'k@pets.lk', phone: '0771234567'),
              )),
        ],
      );

  testWidgets('finds a vet by code and shares the pet after confirming', (tester) async {
    final repo = FakeSharingRepository(doctors: const [nimali]);
    await pump(tester, repo);

    expect(find.text('Only you can see Bruno’s records right now.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Doctor code'), 'dr-7k3m9q');
    await tester.tap(find.text('Find vet'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Nimali Perera'), findsOneWidget);
    await tester.tap(find.text('Give access'));
    await tester.pumpAndSettle();
    expect(find.text('Share Bruno with Dr. Nimali Perera?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Share'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    debugPrint('TEXTS: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).where((t) => t != null).join(' | ')}');

    expect(find.text('Access granted'), findsOneWidget);
    await tester.pumpAndSettle();

    final share = repo.shares.single;
    expect(share.id, 'u1_bruno_doc1');
    expect(share.ownerName, 'Kasun Silva');
    expect(share.ownerPhone, '0771234567');
    expect(share.petName, 'Bruno');
    expect(find.textContaining('Happy Paws'), findsOneWidget); // now in the access list
  });

  testWidgets('explains an unknown code', (tester) async {
    await pump(tester, FakeSharingRepository());

    await tester.enterText(find.widgetWithText(TextField, 'Doctor code'), 'DR-AAAAAA');
    await tester.tap(find.text('Find vet'));
    await tester.pumpAndSettle();

    expect(find.text('No approved vet found with code DR-AAAAAA.'), findsOneWidget);
  });

  testWidgets('removes a vet after confirming', (tester) async {
    final repo = FakeSharingRepository(shares: const [
      PetShare(ownerId: 'u1', petId: 'bruno', doctorId: 'doc1', petName: 'Bruno', doctorName: 'Dr. Nimali Perera'),
    ]);
    await pump(tester, repo);

    await tester.tap(find.byTooltip('Remove access'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(repo.shares, isEmpty);
    expect(repo.calls, ['revoke:u1_bruno_doc1']);
    expect(find.text('Only you can see Bruno’s records right now.'), findsOneWidget);
  });
}
