import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/storage/shared_preferences_provider.dart';
import 'package:petcare/features/authentication/domain/entities/app_user.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/clinics/presentation/providers/clinic_providers.dart';
import 'package:petcare/features/home/domain/entities/dashboard.dart';
import 'package:petcare/features/home/presentation/providers/dashboard_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/profile/domain/entities/user_profile.dart';
import 'package:petcare/features/profile/presentation/providers/profile_providers.dart';
import 'package:petcare/features/profile/presentation/screens/change_password_screen.dart';
import 'package:petcare/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:petcare/features/profile/presentation/screens/faq_screen.dart';
import 'package:petcare/features/profile/presentation/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_clinic_repositories.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_profile_repository.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  const kasun = UserProfile(
    id: 'u1',
    fullName: 'Kasun Silva',
    email: 'k@pets.lk',
    phone: '0771234567',
    city: 'Colombo',
  );

  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;

  setUp(() {
    auth = FakeAuthRepository();
    profiles = FakeProfileRepository(kasun);
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final overrides = <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      authRepositoryProvider.overrideWithValue(auth),
      authStateProvider.overrideWith(
        (ref) => Stream.value(const AppUser(id: 'u1', email: 'k@pets.lk', displayName: 'Kasun Silva')),
      ),
      currentUserIdProvider.overrideWithValue('u1'),
      profileRepositoryProvider.overrideWithValue(profiles),
      petRepositoryProvider.overrideWithValue(FakePetRepository(const [
        Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
        Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat),
      ])),
      clinicRepositoryProvider.overrideWithValue(FakeClinicRepository()),
      dashboardProvider.overrideWith((ref) => Stream.value(Dashboard.empty)),
    ];
    await pumpScreen(tester, screen, overrides: overrides, physicalSize: const Size(1080, 4200));
    await tester.pump();
  }

  group('ProfileScreen', () {
    testWidgets('shows the owner, stats and every settings group', (tester) async {
      await pump(tester, const ProfileScreen());

      expect(find.text('Kasun Silva'), findsOneWidget);
      expect(find.text('0771234567'), findsOneWidget);
      expect(find.text('Colombo'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // pets
      expect(find.text('Pets'), findsOneWidget);

      for (final label in [
        'Edit profile',
        'Change password',
        'Notifications',
        'Appearance',
        'Help & FAQ',
        'Contact support',
        'Share PetCare',
        'About PetCare',
        'Log out',
        'Delete account',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }

      await tester.tap(find.text('Help & FAQ'));
      await tester.pumpAndSettle();
      expect(find.text('route: /profile/faq'), findsOneWidget);
    });

    testWidgets('Google accounts have no change-password option', (tester) async {
      auth.usesPassword = false;
      await pump(tester, const ProfileScreen());

      expect(find.text('Change password'), findsNothing);
    });

    testWidgets('delete account needs the password and a confirmation', (tester) async {
      await pump(tester, const ProfileScreen());

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      final deleteButton = find.widgetWithText(FilledButton, 'Delete forever');
      expect(tester.widget<FilledButton>(deleteButton).onPressed, isNull);

      await tester.enterText(find.widgetWithText(TextField, 'Your password'), 'secret1');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<FilledButton>(deleteButton).onPressed, isNotNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(auth.calls, isEmpty);
    });
  });

  testWidgets('EditProfileScreen saves changed details', (tester) async {
    await pump(tester, const EditProfileScreen());

    expect(find.text('k@pets.lk'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Full name *'), 'Kasun Perera');
    await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'Kandy');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(profiles.profile!.fullName, 'Kasun Perera');
    expect(profiles.profile!.city, 'Kandy');
    expect(find.text('previous page'), findsOneWidget);
  });

  testWidgets('EditProfileScreen validates the phone number', (tester) async {
    await pump(tester, const EditProfileScreen());

    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '12');
    await tester.tap(find.text('Save changes'));
    await tester.pump();

    expect(find.text('Enter a valid phone number'), findsOneWidget);
    expect(profiles.calls, isEmpty);
  });

  testWidgets('ChangePasswordScreen checks the confirmation, then updates', (tester) async {
    await pump(tester, const ChangePasswordScreen());

    await tester.enterText(find.widgetWithText(TextFormField, 'Current password'), 'old12345');
    await tester.enterText(find.widgetWithText(TextFormField, 'New password'), 'new12345');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm new password'), 'other123');
    await tester.tap(find.text('Update password'));
    await tester.pump();
    expect(auth.calls, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm new password'), 'new12345');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(auth.calls, ['changePassword:old12345:new12345']);
    expect(find.text('previous page'), findsOneWidget);
  });

  testWidgets('FaqScreen search filters answers and shows an empty state', (tester) async {
    await pump(tester, const FaqScreen());

    expect(find.text('How do I add a pet?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'offline');
    await tester.pumpAndSettle();

    expect(find.text('How do I add a pet?'), findsNothing);
    expect(find.text('Can I use PetCare offline?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('No answers found'), findsOneWidget);
  });
}
