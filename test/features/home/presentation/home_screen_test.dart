import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:petcare/features/authentication/domain/entities/app_user.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/home/presentation/screens/home_screen.dart';
import 'package:petcare/features/medications/domain/entities/dose_time.dart';
import 'package:petcare/features/medications/domain/entities/medication.dart';
import 'package:petcare/features/medications/presentation/providers/medication_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';
import 'package:petcare/features/vaccinations/presentation/providers/vaccination_providers.dart';

import '../../../helpers/fake_appointment_repository.dart';
import '../../../helpers/fake_medication_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_vaccination_repository.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  final now = DateTime(2026, 9, 26, 9);

  Future<void> pump(WidgetTester tester, {List<Pet> pets = const []}) => pumpScreen(
        tester,
        const HomeScreen(),
        physicalSize: const Size(1080, 4000),
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(id: 'u1', email: 'k@pets.lk', displayName: 'Kasun Silva'),
            ),
          ),
          currentUserIdProvider.overrideWithValue('u1'),
          clockProvider.overrideWithValue(() => now),
          petRepositoryProvider.overrideWithValue(FakePetRepository(pets)),
          appointmentRepositoryProvider.overrideWithValue(FakeAppointmentRepository([
            Appointment(
              id: 'checkup',
              ownerId: 'u1',
              petId: 'milo',
              dateTime: DateTime(2026, 10, 25, 10, 30),
            ),
          ])),
          vaccinationRepositoryProvider.overrideWithValue(FakeVaccinationRepository([
            Vaccination(
              id: 'dhpp',
              ownerId: 'u1',
              petId: 'bruno',
              vaccineName: 'DHPP',
              dateAdministered: DateTime(2025, 9, 20),
              nextDueDate: DateTime(2026, 9, 20),
            ),
          ])),
          medicationRepositoryProvider.overrideWithValue(FakeMedicationRepository([
            Medication(
              id: 'vit',
              ownerId: 'u1',
              petId: 'bruno',
              name: 'Vitamin Supplement',
              dosage: '1 tablet',
              startDate: DateTime(2026, 9, 1),
              doseTimes: const [DoseTime(8, 0)],
            ),
          ])),
        ],
      );

  testWidgets('without pets shows a welcome call to action', (tester) async {
    await pump(tester);

    expect(find.text('Good Morning, Kasun 👋'), findsOneWidget);
    expect(find.text('Welcome to PetCare'), findsOneWidget);
    expect(find.text('Add Pet'), findsOneWidget);
  });

  testWidgets('shows alerts, pets, today’s doses and upcoming', (tester) async {
    await pump(tester, pets: const [
      Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
      Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat),
    ]);

    expect(find.text('Health alerts (1)'), findsOneWidget);
    expect(find.text('DHPP vaccination is overdue by 6 days'), findsOneWidget);

    expect(find.text('Bruno'), findsWidgets);
    expect(find.text('1 alert'), findsOneWidget);
    expect(find.text('Add pet'), findsOneWidget);

    expect(find.text('Today’s medications'), findsOneWidget);
    expect(find.text('Bruno · Vitamin Supplement'), findsOneWidget);

    expect(find.text('Milo · Routine checkup'), findsOneWidget);
    expect(find.textContaining('Sun, Oct 25'), findsOneWidget);

    expect(find.text('Recent activity'), findsOneWidget);
    // DHPP was given a year ago (outside the 60-day window); Vitamin started 25 days ago.
    expect(find.text('Started Vitamin Supplement'), findsOneWidget);
    expect(find.text('DHPP vaccination given'), findsNothing);
  });

  testWidgets('bell shows the alert count and opens the alerts sheet', (tester) async {
    await pump(tester, pets: const [
      Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
    ]);

    final bell = find.byTooltip('Health alerts');
    expect(find.descendant(of: bell, matching: find.text('1')), findsOneWidget);

    await tester.tap(bell);
    await tester.pumpAndSettle();

    expect(find.text('Health alerts'), findsOneWidget);
    expect(find.text('DHPP vaccination is overdue by 6 days'), findsNWidgets(2));
  });

  testWidgets('tapping an alert opens the record inside the Home tab', (tester) async {
    await pump(tester, pets: const [
      Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
    ]);

    await tester.tap(find.text('DHPP vaccination is overdue by 6 days'));
    await tester.pumpAndSettle();

    expect(find.text('route: /home/vaccination/dhpp'), findsOneWidget);
  });
}
