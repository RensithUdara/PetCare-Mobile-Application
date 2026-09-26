import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/calendar/presentation/screens/calendar_screen.dart';
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
  final now = DateTime(2026, 9, 26, 12);

  Future<void> pump(WidgetTester tester) => pumpScreen(
        tester,
        const CalendarScreen(),
        overrides: [
          currentUserIdProvider.overrideWithValue('u1'),
          clockProvider.overrideWithValue(() => now),
          petRepositoryProvider.overrideWithValue(FakePetRepository(const [
            Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
            Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat),
          ])),
          appointmentRepositoryProvider.overrideWithValue(FakeAppointmentRepository([
            Appointment(
              id: 'today',
              ownerId: 'u1',
              petId: 'milo',
              dateTime: DateTime(2026, 9, 26, 15, 0),
            ),
          ])),
          medicationRepositoryProvider.overrideWithValue(FakeMedicationRepository([
            Medication(
              id: 'vit',
              ownerId: 'u1',
              petId: 'bruno',
              name: 'Vitamin',
              dosage: '1 tablet',
              startDate: DateTime(2026, 9, 1),
              doseTimes: const [DoseTime(8, 0)],
            ),
          ])),
          vaccinationRepositoryProvider.overrideWithValue(FakeVaccinationRepository([
            Vaccination(
              id: 'r',
              ownerId: 'u1',
              petId: 'bruno',
              vaccineName: 'Rabies',
              dateAdministered: DateTime(2025, 9, 26),
              nextDueDate: DateTime(2026, 9, 26),
            ),
          ])),
        ],
      );

  testWidgets('shows today’s events across pets', (tester) async {
    await pump(tester);

    expect(find.text('Bruno · Rabies due'), findsOneWidget);
    expect(find.text('Milo · Routine checkup'), findsOneWidget);
    expect(find.textContaining('All day'), findsOneWidget);
    expect(find.text('Bruno · Vitamin'), findsOneWidget, reason: 'ongoing daily medication');
  });

  testWidgets('pet filter narrows the agenda', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '🐱 Milo'));
    await tester.pumpAndSettle();

    expect(find.text('Milo · Routine checkup'), findsOneWidget);
    expect(find.text('Bruno · Rabies due'), findsNothing);
    expect(find.text('Bruno · Vitamin'), findsNothing);
  });

  testWidgets('tapping an event opens it inside the calendar tab', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Milo · Routine checkup'));
    await tester.pumpAndSettle();

    expect(find.text('route: /calendar/appointment/today'), findsOneWidget);
  });
}
