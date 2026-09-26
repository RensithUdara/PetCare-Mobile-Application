import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/domain/reminder_offset.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/medications/domain/entities/dose_time.dart';
import 'package:petcare/features/medications/domain/entities/medication.dart';
import 'package:petcare/features/notifications/domain/entities/notification_settings.dart';
import 'package:petcare/features/notifications/domain/entities/reminder.dart';
import 'package:petcare/features/notifications/domain/logic/reminder_planner.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);
  String fmt(DateTime d) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}';

  const pets = [
    Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
    Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat),
  ];

  Vaccination vac(String id, DateTime given, DateTime due, {String pet = 'bruno'}) => Vaccination(
        id: id,
        ownerId: 'u1',
        petId: pet,
        vaccineName: 'Rabies',
        dateAdministered: given,
        nextDueDate: due,
        reminder: ReminderOffset.sevenDays,
      );

  final vaccinations = [
    vac('old', DateTime(2025, 10, 5), DateTime(2026, 10, 5)), // superseded
    vac('rabies', DateTime(2026, 9, 1), DateTime(2026, 10, 20)), // reminder Oct 13 09:00
    vac('past', DateTime(2025, 9, 1), DateTime(2026, 9, 28), pet: 'milo'), // reminder Sep 21 (past)
    vac('orphan', DateTime(2026, 9, 1), DateTime(2026, 10, 20), pet: 'gone'),
  ];

  final appointments = [
    Appointment(
      id: 'checkup',
      ownerId: 'u1',
      petId: 'milo',
      dateTime: DateTime(2026, 9, 28, 10, 30), // reminder Sep 27 10:30
    ),
    Appointment(
      id: 'cancelled',
      ownerId: 'u1',
      petId: 'milo',
      dateTime: DateTime(2026, 10, 1, 9),
      status: AppointmentStatus.cancelled,
    ),
  ];

  final medications = [
    Medication(
      id: 'vit',
      ownerId: 'u1',
      petId: 'bruno',
      name: 'Vitamin',
      dosage: '1 tablet',
      frequency: MedicationFrequency.twiceDaily,
      startDate: DateTime(2026, 9, 20),
      doseTimes: const [DoseTime(8, 0), DoseTime(20, 0)],
    ),
    Medication(
      id: 'quiet',
      ownerId: 'u1',
      petId: 'bruno',
      name: 'Drops',
      dosage: '1 drop',
      startDate: DateTime(2026, 9, 20),
      doseTimes: const [DoseTime(9, 0)],
      remindersEnabled: false,
    ),
  ];

  List<PlannedReminder> plan([NotificationSettings settings = const NotificationSettings()]) =>
      planReminders(
        pets: pets,
        vaccinations: vaccinations,
        appointments: appointments,
        medications: medications,
        settings: settings,
        now: now,
        formatTime: fmt,
      );

  test('future reminders only, soonest first', () {
    final p = plan();
    expect(p.map((r) => r.fireAt).toList(), [...p.map((r) => r.fireAt)]..sort());
    expect(p.every((r) => r.fireAt.isAfter(now)), isTrue);
  });

  test('vaccination: current dose only, with relative wording', () {
    final v = plan().where((r) => r.target.category == ReminderCategory.vaccination).toList();
    expect(v.map((r) => r.target.sourceId), ['rabies']);
    expect(v.single.fireAt, DateTime(2026, 10, 13, 9));
    expect(v.single.body, 'Bruno’s Rabies vaccination is due in 7 days.');
  });

  test('appointment: scheduled only, "tomorrow at <time>"', () {
    final a = plan().where((r) => r.target.category == ReminderCategory.appointment).toList();
    expect(a.map((r) => r.target.sourceId), ['checkup']);
    expect(a.single.fireAt, DateTime(2026, 9, 27, 10, 30));
    expect(a.single.body, 'Milo has a veterinary appointment tomorrow at 10:30.');
  });

  test('medication: every dose within the horizon, reminders-off skipped', () {
    final m = plan().where((r) => r.target.category == ReminderCategory.medication).toList();
    // Today 20:00, then 2 doses on each of the next 3 days.
    expect(m, hasLength(1 + 2 * medicationHorizonDays));
    expect(m.first.fireAt, DateTime(2026, 9, 26, 20));
    expect(m.first.body, 'It’s time for Bruno’s Vitamin (1 tablet).');
    expect(m.any((r) => r.target.sourceId == 'quiet'), isFalse);
  });

  test('settings gate categories and the master switch', () {
    expect(plan(const NotificationSettings(enabled: false)), isEmpty);

    final noMeds = plan(const NotificationSettings(medications: false));
    expect(noMeds.any((r) => r.target.category == ReminderCategory.medication), isFalse);
    expect(noMeds.any((r) => r.target.category == ReminderCategory.vaccination), isTrue);
  });

  test('ids are stable, distinct and fit in 31 bits', () {
    final a = plan();
    final b = plan();
    expect(a.map((r) => r.id), b.map((r) => r.id));
    expect(a.map((r) => r.id).toSet(), hasLength(a.length));
    expect(a.every((r) => r.id >= 0 && r.id <= 0x7fffffff), isTrue);
  });

  test('caps the plan at maxPendingReminders', () {
    final many = [
      for (var i = 0; i < 30; i++)
        Medication(
          id: 'm$i',
          ownerId: 'u1',
          petId: 'bruno',
          name: 'Med $i',
          dosage: '1',
          startDate: DateTime(2026, 9, 1),
          doseTimes: const [DoseTime(22, 0)],
        ),
    ];
    final p = planReminders(
      pets: pets,
      vaccinations: const [],
      appointments: const [],
      medications: many,
      settings: const NotificationSettings(),
      now: now,
      formatTime: fmt,
    );
    expect(p, hasLength(maxPendingReminders));
  });

  group('ReminderTarget', () {
    test('round-trips payloads and rejects junk', () {
      const t = ReminderTarget(ReminderCategory.appointment, 'a:b');
      expect(ReminderTarget.tryParse(t.payload), t);
      expect(ReminderTarget.tryParse('nope'), isNull);
      expect(ReminderTarget.tryParse('grooming:1'), isNull);
      expect(ReminderTarget.tryParse('vaccination:'), isNull);
      expect(ReminderTarget.tryParse(null), isNull);
    });
  });
}
