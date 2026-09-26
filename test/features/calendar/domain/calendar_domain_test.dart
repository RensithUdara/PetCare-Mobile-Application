import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/calendar/domain/entities/calendar_event.dart';
import 'package:petcare/features/calendar/domain/logic/calendar_events.dart';
import 'package:petcare/features/calendar/domain/usecases/watch_calendar_events.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/vaccinations/domain/entities/vaccination.dart';

import '../../../helpers/fake_appointment_repository.dart';
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
    Appointment(
      id: 'missed',
      ownerId: 'u1',
      petId: 'milo',
      dateTime: DateTime(2026, 9, 1, 9),
    ),
  ];

  group('buildCalendarEvents', () {
    final events = buildCalendarEvents(
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

    test('groupEventsByDay keys by date only', () {
      final byDay = groupEventsByDay(events);
      expect(byDay[DateTime(2026, 10, 20)]!.map((e) => e.sourceId), ['r25', 'checkup']);
      expect(byDay[DateTime(2026, 9, 1)], hasLength(1));
    });
  });

  test('WatchCalendarEvents reacts to changes in any source', () async {
    final petRepo = FakePetRepository(pets);
    final apptRepo = FakeAppointmentRepository();
    final vacRepo = FakeVaccinationRepository();
    final stream = WatchCalendarEvents(petRepo, apptRepo, vacRepo, () => now)('u1');

    final emissions = <List<CalendarEvent>>[];
    final sub = stream.listen(emissions.add);
    await pumpEventQueue();
    expect(emissions.last, isEmpty);

    await apptRepo.save(appointments.first);
    await pumpEventQueue();
    expect(emissions.last.map((e) => e.sourceId), ['checkup']);

    await vacRepo.save(vaccinations[1]);
    await pumpEventQueue();
    expect(emissions.last.map((e) => e.sourceId), ['r25', 'checkup']);

    await sub.cancel();
  });
}
