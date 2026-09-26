import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/domain/reminder_offset.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/appointments/domain/entities/appointment_overview.dart';
import 'package:petcare/features/appointments/domain/logic/appointment_status.dart';
import 'package:petcare/features/appointments/domain/usecases/save_appointment.dart';
import 'package:petcare/features/appointments/domain/usecases/update_appointment_status.dart';

import '../../../helpers/fake_appointment_repository.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);
  DateTime clock() => now;

  Appointment appt(
    String id,
    DateTime at, {
    AppointmentStatus status = AppointmentStatus.scheduled,
    ReminderOffset? reminder = ReminderOffset.oneDay,
  }) =>
      Appointment(
        id: id,
        ownerId: 'u1',
        petId: 'p1',
        dateTime: at,
        status: status,
        reminder: reminder,
      );

  group('appointmentDisplayStatus', () {
    AppointmentDisplayStatus status(Appointment a) => appointmentDisplayStatus(a, now);

    test('scheduled: upcoming / today / past', () {
      expect(status(appt('a', DateTime(2026, 9, 27, 9))), AppointmentDisplayStatus.upcoming);
      expect(status(appt('a', DateTime(2026, 9, 26, 18))), AppointmentDisplayStatus.today);
      expect(status(appt('a', DateTime(2026, 9, 26, 8))), AppointmentDisplayStatus.past);
    });

    test('completed and cancelled win regardless of date', () {
      expect(
        status(appt('a', DateTime(2027), status: AppointmentStatus.cancelled)),
        AppointmentDisplayStatus.cancelled,
      );
      expect(
        status(appt('a', DateTime(2025), status: AppointmentStatus.completed)),
        AppointmentDisplayStatus.completed,
      );
    });
  });

  test('buildAppointmentOverview splits and sorts', () {
    final overview = buildAppointmentOverview([
      appt('later', DateTime(2026, 10, 25, 10)),
      appt('soon', DateTime(2026, 9, 26, 15)),
      appt('done', DateTime(2026, 8, 1), status: AppointmentStatus.completed),
      appt('missed', DateTime(2026, 7, 1)),
      appt('cancelled', DateTime(2026, 9, 1), status: AppointmentStatus.cancelled),
    ], now);

    expect(overview.upcoming.map((e) => e.appointment.id), ['soon', 'later']);
    expect(overview.next?.status, AppointmentDisplayStatus.today);
    // "Needs update" first, then newest first.
    expect(overview.history.map((e) => e.appointment.id), ['missed', 'cancelled', 'done']);
    expect(overview.count(AppointmentDisplayStatus.completed), 1);
    expect(overview.total, 5);
  });

  group('reminderDate', () {
    test('N days before at the same time', () {
      expect(appt('a', DateTime(2026, 10, 25, 10, 30)).reminderDate, DateTime(2026, 10, 24, 10, 30));
      expect(
        appt('a', DateTime(2026, 11, 1, 9), reminder: ReminderOffset.sevenDays).reminderDate,
        DateTime(2026, 10, 25, 9),
      );
    });

    test('"on the day" means two hours before', () {
      expect(
        appt('a', DateTime(2026, 10, 25, 10, 30), reminder: ReminderOffset.onTheDay).reminderDate,
        DateTime(2026, 10, 25, 8, 30),
      );
    });

    test('none when disabled or no longer scheduled', () {
      expect(appt('a', DateTime(2026, 10, 25), reminder: null).reminderDate, isNull);
      expect(
        appt('a', DateTime(2026, 10, 25), status: AppointmentStatus.cancelled).reminderDate,
        isNull,
      );
    });
  });

  group('SaveAppointment', () {
    late FakeAppointmentRepository repo;
    late SaveAppointment save;

    setUp(() {
      repo = FakeAppointmentRepository();
      save = SaveAppointment(repo, clock);
    });

    test('assigns id/owner and trims optional text to null', () async {
      final id = await save(
        ownerId: 'u1',
        appointment: Appointment(
          ownerId: '',
          petId: 'p1',
          dateTime: DateTime(2026, 10, 25, 10, 30),
          clinic: '  Happy Paws ',
          reason: '   ',
        ),
      );

      final saved = repo.items.single;
      expect(saved.id, id);
      expect(saved.ownerId, 'u1');
      expect(saved.clinic, 'Happy Paws');
      expect(saved.reason, isNull);
      expect(saved.status, AppointmentStatus.scheduled);
    });

    test('a new appointment in the past is logged as completed', () async {
      await save(
        ownerId: 'u1',
        appointment: Appointment(ownerId: '', petId: 'p1', dateTime: DateTime(2026, 9, 1)),
      );
      expect(repo.items.single.status, AppointmentStatus.completed);
    });

    test('requires a pet', () {
      expect(
        save(ownerId: 'u1', appointment: Appointment(ownerId: '', petId: '', dateTime: now)),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'invalid-pet')),
      );
    });
  });

  group('UpdateAppointmentStatus', () {
    test('cannot complete an appointment that has not started', () async {
      final repo = FakeAppointmentRepository();
      final update = UpdateAppointmentStatus(repo, clock);

      await expectLater(
        update(
          appointment: appt('a', DateTime(2026, 10, 1)),
          status: AppointmentStatus.completed,
        ),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'not-started')),
      );
      expect(repo.items, isEmpty);
    });

    test('cancels and completes', () async {
      final repo = FakeAppointmentRepository();
      final update = UpdateAppointmentStatus(repo, clock);

      await update(appointment: appt('a', DateTime(2026, 10, 1)), status: AppointmentStatus.cancelled);
      await update(appointment: appt('b', DateTime(2026, 9, 1)), status: AppointmentStatus.completed);

      expect(repo.items.map((a) => (a.id, a.status)), [
        ('a', AppointmentStatus.cancelled),
        ('b', AppointmentStatus.completed),
      ]);
    });
  });
}
