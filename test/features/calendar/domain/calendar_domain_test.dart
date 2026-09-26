import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/calendar/domain/entities/calendar_event.dart';
import 'package:petcare/features/calendar/domain/entities/calendar_snapshot.dart';
import 'package:petcare/features/calendar/domain/logic/calendar_events.dart';
import 'package:petcare/features/calendar/domain/usecases/watch_calendar.dart';
import 'package:petcare/features/medications/domain/entities/dose_time.dart';
import 'package:petcare/features/medications/domain/entities/medication.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';

import '../../../helpers/fake_appointment_repository.dart';
import '../../../helpers/fake_medication_repository.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_vaccination_repository.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);

  const pets = [
    Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
    Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat),
  ];

  Vaccination vac(String id, String petId, String name, DateTime given, DateTime? due) =>
      Vaccination(
        id: id,
        ownerId: 'u1',
        petId: petId,
        vaccineName: name,
        dateAdministered: given,
        nextDueDate: due,
      );

  final vaccinations = [
    vac('r24', 'bruno', 'Rabies', DateTime(2024, 10, 20), DateTime(2025, 10, 20)),
    vac('r25', 'bruno', 'Rabies', DateTime(2025, 10, 20), DateTime(2026, 10, 20)),
    vac('once', 'bruno', 'Leptospirosis', DateTime(2026, 1, 1), null),
    vac('orphan', 'deleted-pet', 'Rabies', DateTime(2025), DateTime(2026, 10, 1)),
  ];

  final appointments = [
    Appointment(
      id: 'checkup',
      ownerId: 'u1',
      petId: 'milo',
      dateTime: DateTime(2026, 10, 20, 10, 30),
      reason: 'Annual check',
    ),
    Appointment(id: 'missed', ownerId: 'u1', petId: 'milo', dateTime: DateTime(2026, 9, 1, 9)),
  ];

  final vitamin = Medication(
    id: 'vit',
    ownerId: 'u1',
    petId: 'bruno',
    name: 'Vitamin Supplement',
    dosage: '1 tablet',
    frequency: MedicationFrequency.twiceDaily,
    startDate: DateTime(2026, 9, 20),
    endDate: DateTime(2026, 10, 19),
    doseTimes: const [DoseTime(8, 0), DoseTime(20, 0)],
  );

  group('buildDatedEvents', () {
    final events = buildDatedEvents(
      pets: pets,
      appointments: appointments,
      vaccinations: vaccinations,
      now: now,
    );

    test('only current vaccine doses with a due date; skips deleted pets', () {
      final vaccineEvents = events.where((e) => e.kind == CalendarEventKind.vaccinationDue);
      expect(vaccineEvents.map((e) => e.sourceId), ['r25']);
      expect(vaccineEvents.single.title, 'Rabies due');
      expect(vaccineEvents.single.isAllDay, isTrue);
    });

    test('appointments carry pet name, subtitle and mapped status', () {
      final checkup = events.firstWhere((e) => e.sourceId == 'checkup');
      expect(checkup.petName, 'Milo');
      expect(checkup.subtitle, 'Annual check');
      expect(checkup.status, CalendarEventStatus.upcoming);
      expect(
        events.firstWhere((e) => e.sourceId == 'missed').status,
        CalendarEventStatus.needsUpdate,
      );
    });

    test('sorted by day, all-day items first', () {
      expect(events.map((e) => e.sourceId), ['missed', 'r25', 'checkup']);
    });
  });

  group('CalendarSnapshot', () {
    final snapshot = buildCalendarSnapshot(
      pets: pets,
      appointments: appointments,
      vaccinations: vaccinations,
      medications: [
        vitamin,
        vitamin.copyWith(id: 'orphan-med', petId: 'deleted-pet'),
      ],
      now: now,
    );

    test('eventsOn merges dated events and expands medication doses', () {
      final events = snapshot.eventsOn(DateTime(2026, 10, 19));
      final med = events.single;
      expect(med.kind, CalendarEventKind.medication);
      expect(med.title, 'Vitamin Supplement');
      expect(med.doseTimes, [DateTime(2026, 10, 19, 8), DateTime(2026, 10, 19, 20)]);
      expect(med.status, CalendarEventStatus.upcoming);
    });

    test('no medication events outside the course', () {
      expect(snapshot.eventsOn(DateTime(2026, 10, 20)).map((e) => e.sourceId), ['r25', 'checkup']);
      expect(snapshot.eventsOn(DateTime(2026, 9, 19)), isEmpty);
    });

    test('medication status by day relative to today', () {
      expect(snapshot.eventsOn(DateTime(2026, 9, 25)).single.status, CalendarEventStatus.completed);
      expect(snapshot.eventsOn(DateTime(2026, 9, 26)).single.status, CalendarEventStatus.today);
    });

    test('forPet filters dated events and medications', () {
      final milo = snapshot.forPet('milo');
      expect(milo.eventsOn(DateTime(2026, 10, 1)), isEmpty); // no vitamin for Milo
      expect(milo.eventsOn(DateTime(2026, 10, 20)).map((e) => e.sourceId), ['checkup']);
    });

    test('empty snapshot has no events', () {
      expect(CalendarSnapshot.empty.eventsOn(now), isEmpty);
    });
  });

  test('WatchCalendar reacts to changes in any source', () async {
    final apptRepo = FakeAppointmentRepository();
    final vacRepo = FakeVaccinationRepository();
    final medRepo = FakeMedicationRepository();
    final stream = WatchCalendar(
      FakePetRepository(pets),
      apptRepo,
      vacRepo,
      medRepo,
      () => now,
    )('u1');

    final emissions = <CalendarSnapshot>[];
    final sub = stream.listen(emissions.add);
    await pumpEventQueue();
    expect(emissions.last.eventsOn(DateTime(2026, 10, 19)), isEmpty);

    await medRepo.save(vitamin);
    await appointmentsSave(apptRepo, appointments.first);
    await pumpEventQueue();
    expect(emissions.last.eventsOn(DateTime(2026, 10, 19)).single.sourceId, 'vit');
    expect(emissions.last.eventsOn(DateTime(2026, 10, 20)).single.sourceId, 'checkup');

    await sub.cancel();
  });
}

Future<void> appointmentsSave(FakeAppointmentRepository repo, Appointment a) => repo.save(a);
