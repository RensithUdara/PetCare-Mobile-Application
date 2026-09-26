import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:petcare/features/appointments/presentation/screens/appointment_details_screen.dart';
import 'package:petcare/features/appointments/presentation/screens/appointment_form_screen.dart';
import 'package:petcare/features/appointments/presentation/screens/appointments_screen.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';

import '../../../helpers/fake_appointment_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);
  const milo = Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat);

  Future<void> pump(WidgetTester tester, FakeAppointmentRepository repo, Widget screen) =>
      pumpScreen(tester, screen, overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        clockProvider.overrideWithValue(() => now),
        petRepositoryProvider.overrideWithValue(FakePetRepository([milo])),
        appointmentRepositoryProvider.overrideWithValue(repo),
      ]);

  Appointment appt(String id, DateTime at, {AppointmentStatus? status}) => Appointment(
        id: id,
        ownerId: 'u1',
        petId: 'milo',
        dateTime: at,
        status: status ?? AppointmentStatus.scheduled,
        clinic: 'Happy Paws',
      );

  testWidgets('list shows upcoming count and cards', (tester) async {
    final repo = FakeAppointmentRepository([
      appt('a', DateTime(2026, 10, 25, 10, 30)),
      appt('b', DateTime(2026, 8, 1, 9), status: AppointmentStatus.completed),
    ]);
    await pump(tester, repo, const AppointmentsScreen(petId: 'milo'));

    expect(find.text('Milo’s Appointments'), findsOneWidget);
    expect(find.text('Upcoming (1)'), findsOneWidget);
    expect(find.text('Routine checkup'), findsOneWidget);
    expect(find.textContaining('10:30'), findsOneWidget); // intl uses U+202F before AM
  });

  group('AppointmentFormScreen', () {
    testWidgets('requires date and time', (tester) async {
      final repo = FakeAppointmentRepository();
      await pump(tester, repo, const AppointmentFormScreen(petId: 'milo'));

      await tester.tap(find.text('Schedule Appointment'));
      await tester.pump();

      expect(find.text('Date is required'), findsOneWidget);
      expect(find.text('Time is required'), findsOneWidget);
      expect(repo.items, isEmpty);
    });

    testWidgets('saves with prefilled pet and date', (tester) async {
      final repo = FakeAppointmentRepository();
      await pump(
        tester,
        repo,
        AppointmentFormScreen(petId: 'milo', initialDate: DateTime(2026, 10, 25)),
      );

      await tester.tap(find.text('Dental'));
      await tester.tap(find.widgetWithText(InkWell, 'Time *'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // accept default 9:00 AM
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Clinic'), 'Happy Paws');

      await tester.tap(find.text('Schedule Appointment'));
      await tester.pumpAndSettle();

      final saved = repo.items.single;
      expect(saved.petId, 'milo');
      expect(saved.type, AppointmentType.dental);
      expect(saved.dateTime, DateTime(2026, 10, 25, 9));
      expect(saved.clinic, 'Happy Paws');
      expect(find.text('previous page'), findsOneWidget);
    });
  });

  group('AppointmentDetailsScreen', () {
    testWidgets('past appointment asks for an update and can be completed', (tester) async {
      final repo = FakeAppointmentRepository([appt('a', DateTime(2026, 9, 20, 10))]);
      await pump(tester, repo, const AppointmentDetailsScreen(appointmentId: 'a'));

      expect(find.text('Needs update'), findsOneWidget);
      expect(find.text('Did this visit happen?'), findsOneWidget);

      await tester.tap(find.text('Mark as Completed'));
      await tester.pumpAndSettle();

      expect(repo.items.single.status, AppointmentStatus.completed);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Reopen'), findsOneWidget);
    });

    testWidgets('future appointment can be cancelled but not completed', (tester) async {
      final repo = FakeAppointmentRepository([appt('a', DateTime(2026, 10, 25, 10, 30))]);
      await pump(tester, repo, const AppointmentDetailsScreen(appointmentId: 'a'));

      expect(find.text('Mark as Completed'), findsNothing);

      await tester.tap(find.text('Cancel Appointment'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel appointment'));
      await tester.pumpAndSettle();

      expect(repo.items.single.status, AppointmentStatus.cancelled);
    });
  });
}
