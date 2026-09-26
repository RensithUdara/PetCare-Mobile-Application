import '../../../../core/utils/date_utils.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/entities/appointment_overview.dart';
import '../../../appointments/domain/logic/appointment_status.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../calendar/domain/logic/calendar_events.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/logic/medication_schedule.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../vaccinations/domain/entities/vaccination.dart';
import '../../../vaccinations/domain/entities/vaccination_overview.dart';
import '../../../vaccinations/domain/logic/vaccination_status.dart';
import '../entities/dashboard.dart';

/// How far ahead "Upcoming" looks.
const upcomingWindowDays = 30;
const maxUpcoming = 5;

/// How far back "Recent activity" looks.
const activityWindowDays = 60;
const maxActivity = 5;

Dashboard buildDashboard({
  required List<Pet> pets,
  required List<Appointment> appointments,
  required List<Vaccination> vaccinations,
  required List<Medication> medications,
  required DateTime now,
}) {
  if (pets.isEmpty) return Dashboard.empty;

  final names = {for (final p in pets) p.id: p.name};
  final today = dateOnly(now);

  final snapshot = buildCalendarSnapshot(
    pets: pets,
    appointments: appointments,
    vaccinations: vaccinations,
    medications: medications,
    now: now,
  );

  // ── Upcoming (appointments + vaccination due dates) ──────────────────
  final upcoming = <CalendarEvent>[];
  for (var i = 0; i <= upcomingWindowDays; i++) {
    for (final e in snapshot.eventsOn(DateTime(today.year, today.month, today.day + i))) {
      final isFuture = e.status == CalendarEventStatus.upcoming ||
          e.status == CalendarEventStatus.today;
      if (e.kind != CalendarEventKind.medication && isFuture) upcoming.add(e);
    }
  }

  // ── Alerts ───────────────────────────────────────────────────────────
  final alerts = <HealthAlert>[];
  final vaccinationsByPet = <String, List<Vaccination>>{};
  for (final v in vaccinations) {
    if (names.containsKey(v.petId)) vaccinationsByPet.putIfAbsent(v.petId, () => []).add(v);
  }
  for (final MapEntry(key: petId, value: list) in vaccinationsByPet.entries) {
    for (final e in buildVaccinationOverview(list, now).current) {
      if (e.status != VaccinationStatus.overdue) continue;
      alerts.add(HealthAlert(
        kind: HealthAlertKind.vaccinationOverdue,
        sourceId: e.vaccination.id,
        petId: petId,
        petName: names[petId]!,
        title: e.vaccination.vaccineName,
        date: e.vaccination.nextDueDate!,
      ));
    }
  }
  for (final a in appointments) {
    if (!names.containsKey(a.petId)) continue;
    if (appointmentDisplayStatus(a, now) != AppointmentDisplayStatus.past) continue;
    alerts.add(HealthAlert(
      kind: HealthAlertKind.appointmentNeedsUpdate,
      sourceId: a.id,
      petId: a.petId,
      petName: names[a.petId]!,
      title: a.type.label,
      date: a.dateTime,
    ));
  }
  // Overdue vaccinations first (oldest first), then appointments.
  alerts.sort((a, b) {
    if (a.kind != b.kind) return a.kind.index.compareTo(b.kind.index);
    return a.date.compareTo(b.date);
  });

  // ── Recent activity ──────────────────────────────────────────────────
  bool isRecent(DateTime d) {
    final days = daysBetween(d, now);
    return days >= 0 && days <= activityWindowDays && !d.isAfter(now);
  }

  final activity = <ActivityItem>[
    for (final v in vaccinations)
      if (names[v.petId] case final petName? when isRecent(v.dateAdministered))
        ActivityItem(
          kind: ActivityKind.vaccinationGiven,
          sourceId: v.id,
          petId: v.petId,
          petName: petName,
          title: v.vaccineName,
          date: v.dateAdministered,
        ),
    for (final a in appointments)
      if (names[a.petId] case final petName?
          when a.status == AppointmentStatus.completed && isRecent(a.dateTime))
        ActivityItem(
          kind: ActivityKind.appointmentCompleted,
          sourceId: a.id,
          petId: a.petId,
          petName: petName,
          title: a.type.label,
          date: a.dateTime,
        ),
    for (final m in medications)
      if (names[m.petId] case final petName? when isRecent(m.startDate))
        ActivityItem(
          kind: ActivityKind.medicationStarted,
          sourceId: m.id,
          petId: m.petId,
          petName: petName,
          title: m.name,
          date: m.startDate,
        ),
  ]..sort((a, b) => b.date.compareTo(a.date));

  // ── Pet summaries ────────────────────────────────────────────────────
  final summaries = [
    for (final pet in pets)
      PetSummary(
        pet: pet,
        alertCount: alerts.where((a) => a.petId == pet.id).length,
        activeMedications: medications
            .where((m) => m.petId == pet.id && medicationStatus(m, now) == MedicationStatus.active)
            .length,
        nextEvent: upcoming.where((e) => e.petId == pet.id).firstOrNull,
      ),
  ];

  return Dashboard(
    pets: summaries,
    alerts: alerts,
    todaysDoses: snapshot
        .eventsOn(today)
        .where((e) => e.kind == CalendarEventKind.medication)
        .toList(),
    upcoming: upcoming.take(maxUpcoming).toList(),
    recentActivity: activity.take(maxActivity).toList(),
  );
}
