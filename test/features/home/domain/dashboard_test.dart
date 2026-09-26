import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/appointments/domain/entities/appointment.dart';
import 'package:petcare/features/calendar/domain/entities/calendar_event.dart';
import 'package:petcare/features/home/domain/entities/dashboard.dart';
import 'package:petcare/features/home/domain/logic/dashboard_builder.dart';
import 'package:petcare/features/home/domain/usecases/watch_dashboard.dart';
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

  const bruno = Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog);
  const milo = Pet(id: 'milo', ownerId: 'u1', name: 'Milo', species: PetSpecies.cat);

  Vaccination vac(String id, String petId, String name, DateTime given, DateTime? due) =>
      Vaccination(
        id: id,
        ownerId: 'u1',
        petId: petId,
        vaccineName: name,
        dateAdministered: given,
        nextDueDate: due,
      );

  Appointment appt(String id, String petId, DateTime at, [AppointmentStatus? status]) =>
      Appointment(
        id: id,
        ownerId: 'u1',
        petId: petId,
        dateTime: at,
        status: status ?? AppointmentStatus.scheduled,
      );

  final vaccinations = [
    vac('rabies', 'bruno', 'Rabies', DateTime(2025, 10, 20), DateTime(2026, 10, 20)),
    vac('dhpp', 'bruno', 'DHPP', DateTime(2025, 9, 1), DateTime(2026, 9, 1)), // overdue
    vac('fvrcp', 'milo', 'FVRCP', DateTime(2026, 9, 10), DateTime(2027, 9, 10)), // recent
    vac('orphan', 'gone', 'Rabies', DateTime(2025), DateTime(2026, 1, 1)),
  ];
  final appointments = [
    appt('checkup', 'milo', DateTime(2026, 10, 1, 10)),
    appt('far', 'milo', DateTime(2026, 12, 1, 10)), // beyond 30 days
    appt('missed', 'bruno', DateTime(2026, 9, 20, 9)), // needs update
    appt('done', 'milo', DateTime(2026, 9, 15, 9), AppointmentStatus.completed),
    appt('cancelled', 'milo', DateTime(2026, 10, 2, 9), AppointmentStatus.cancelled),
  ];
  final medications = [
    Medication(
      id: 'vit',
      ownerId: 'u1',
      petId: 'bruno',
      name: 'Vitamin',
      dosage: '1 tablet',
      startDate: DateTime(2026, 9, 20),
      doseTimes: const [DoseTime(8, 0)],
    ),
    Medication(
      id: 'old',
      ownerId: 'u1',
      petId: 'milo',
      name: 'Antibiotic',
      dosage: '5 ml',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 10),
      doseTimes: const [DoseTime(9, 0)],
    ),
  ];

  final dashboard = buildDashboard(
    pets: const [bruno, milo],
    appointments: appointments,
    vaccinations: vaccinations,
    medications: medications,
    now: now,
  );

  test('no pets gives the empty dashboard', () {
    final d = buildDashboard(pets: const [], appointments: [], vaccinations: [], medications: [], now: now);
    expect(d, same(Dashboard.empty));
    expect(d.hasPets, isFalse);
  });

  test('alerts: overdue vaccinations first, then appointments needing update', () {
    expect(dashboard.alerts.map((a) => (a.kind, a.sourceId)), [
      (HealthAlertKind.vaccinationOverdue, 'dhpp'),
      (HealthAlertKind.appointmentNeedsUpdate, 'missed'),
    ]);
    expect(dashboard.alerts.first.petName, 'Bruno');
  });

  test('upcoming: next 30 days of appointments and due dates only', () {
    expect(dashboard.upcoming.map((e) => e.sourceId), ['checkup', 'rabies']);
    expect(dashboard.upcoming.every((e) => e.kind != CalendarEventKind.medication), isTrue);
  });

  test('today’s doses come from active medications', () {
    expect(dashboard.todaysDoses.map((e) => e.sourceId), ['vit']);
    expect(dashboard.todaysDoses.single.doseTimes, [DateTime(2026, 9, 26, 8)]);
  });

  test('recent activity is newest first within 60 days', () {
    expect(dashboard.recentActivity.map((a) => (a.kind, a.sourceId)), [
      (ActivityKind.medicationStarted, 'vit'),
      (ActivityKind.appointmentCompleted, 'done'),
      (ActivityKind.vaccinationGiven, 'fvrcp'),
    ]);
  });

  test('pet summaries carry alert counts, active meds and next event', () {
    final b = dashboard.pets.firstWhere((s) => s.pet.id == 'bruno');
    final m = dashboard.pets.firstWhere((s) => s.pet.id == 'milo');
    expect(b.alertCount, 2);
    expect(b.activeMedications, 1);
    expect(b.nextEvent?.sourceId, 'rabies');
    expect(m.alertCount, 0);
    expect(m.activeMedications, 0);
    expect(m.nextEvent?.sourceId, 'checkup');
  });

  test('WatchDashboard updates when records change', () async {
    final vacRepo = FakeVaccinationRepository();
    final stream = WatchDashboard(
      FakePetRepository(const [bruno]),
      FakeAppointmentRepository(),
      vacRepo,
      FakeMedicationRepository(),
      () => now,
    )('u1');

    final emissions = <Dashboard>[];
    final sub = stream.listen(emissions.add);
    await pumpEventQueue();
    expect(emissions.last.alerts, isEmpty);

    await vacRepo.save(vaccinations[1]);
    await pumpEventQueue();
    expect(emissions.last.alerts.single.sourceId, 'dhpp');

    await sub.cancel();
  });
}
