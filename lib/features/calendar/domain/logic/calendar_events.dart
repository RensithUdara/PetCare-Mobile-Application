import '../../../../core/utils/date_utils.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/entities/appointment_overview.dart';
import '../../../appointments/domain/logic/appointment_status.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../vaccinations/domain/entities/vaccination.dart';
import '../../../vaccinations/domain/entities/vaccination_overview.dart';
import '../../../vaccinations/domain/logic/vaccination_status.dart';
import '../entities/calendar_event.dart';

/// Merges appointments and vaccination due dates of all [pets] into one
/// chronologically sorted list. Records of deleted pets are skipped.
List<CalendarEvent> buildCalendarEvents({
  required List<Pet> pets,
  required List<Appointment> appointments,
  required List<Vaccination> vaccinations,
  required DateTime now,
}) {
  final petNames = {for (final p in pets) p.id: p.name};
  final events = <CalendarEvent>[];

  for (final a in appointments) {
    final petName = petNames[a.petId];
    if (petName == null) continue;
    events.add(CalendarEvent(
      kind: CalendarEventKind.appointment,
      sourceId: a.id,
      petId: a.petId,
      petName: petName,
      title: a.type.label,
      subtitle: a.reason ?? a.clinic,
      dateTime: a.dateTime,
      status: switch (appointmentDisplayStatus(a, now)) {
        AppointmentDisplayStatus.upcoming => CalendarEventStatus.upcoming,
        AppointmentDisplayStatus.today => CalendarEventStatus.today,
        AppointmentDisplayStatus.past => CalendarEventStatus.needsUpdate,
        AppointmentDisplayStatus.completed => CalendarEventStatus.completed,
        AppointmentDisplayStatus.cancelled => CalendarEventStatus.cancelled,
      },
    ));
  }

  // Only the latest dose of each vaccine has a meaningful due date.
  final byPet = <String, List<Vaccination>>{};
  for (final v in vaccinations) {
    if (petNames.containsKey(v.petId)) byPet.putIfAbsent(v.petId, () => []).add(v);
  }
  for (final MapEntry(key: petId, value: list) in byPet.entries) {
    for (final entry in buildVaccinationOverview(list, now).current) {
      final due = entry.vaccination.nextDueDate;
      if (due == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.vaccinationDue,
        sourceId: entry.vaccination.id,
        petId: petId,
        petName: petNames[petId]!,
        title: '${entry.vaccination.vaccineName} due',
        dateTime: dateOnly(due),
        isAllDay: true,
        status: switch (entry.status) {
          VaccinationStatus.overdue => CalendarEventStatus.overdue,
          _ when daysBetween(now, due) == 0 => CalendarEventStatus.today,
          _ => CalendarEventStatus.upcoming,
        },
      ));
    }
  }

  events.sort((a, b) {
    final byDay = dateOnly(a.dateTime).compareTo(dateOnly(b.dateTime));
    if (byDay != 0) return byDay;
    // All-day items first within a day, then by time.
    if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
    return a.dateTime.compareTo(b.dateTime);
  });
  return events;
}

/// Groups (already sorted) events by calendar day.
Map<DateTime, List<CalendarEvent>> groupEventsByDay(List<CalendarEvent> events) {
  final map = <DateTime, List<CalendarEvent>>{};
  for (final e in events) {
    map.putIfAbsent(dateOnly(e.dateTime), () => []).add(e);
  }
  return map;
}
