import 'package:meta/meta.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/logic/medication_schedule.dart';
import 'calendar_event.dart';

/// A medication with the name of the pet it belongs to.
typedef PetMedication = ({Medication medication, String petName});

/// Everything the calendar needs at one moment.
///
/// One-off events (appointments, vaccination due dates) are precomputed;
/// recurring medication doses are expanded lazily per day by [eventsOn], so
/// ongoing medications never produce an unbounded list.
@immutable
class CalendarSnapshot {
  CalendarSnapshot({
    required List<CalendarEvent> datedEvents,
    required this.medications,
    required this.now,
  }) : _byDay = _group(datedEvents);

  static final empty = CalendarSnapshot(datedEvents: const [], medications: const [], now: DateTime(0));

  final List<PetMedication> medications;
  final DateTime now;
  final Map<DateTime, List<CalendarEvent>> _byDay;

  static Map<DateTime, List<CalendarEvent>> _group(List<CalendarEvent> events) {
    final map = <DateTime, List<CalendarEvent>>{};
    for (final e in events) {
      map.putIfAbsent(dateOnly(e.dateTime), () => []).add(e);
    }
    return map;
  }

  /// All events on [day]: all-day items first, then by time.
  List<CalendarEvent> eventsOn(DateTime day) {
    final date = dateOnly(day);
    final events = [...?_byDay[date], ..._medicationEventsOn(date)];
    events.sort((a, b) {
      if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
      return a.dateTime.compareTo(b.dateTime);
    });
    return events;
  }

  List<CalendarEvent> _medicationEventsOn(DateTime date) {
    final offset = daysBetween(now, date);
    final status = offset < 0
        ? CalendarEventStatus.completed
        : offset == 0
            ? CalendarEventStatus.today
            : CalendarEventStatus.upcoming;
    return [
      for (final (:medication, :petName) in medications)
        if (dosesOn(medication, date) case final doses when doses.isNotEmpty)
          CalendarEvent(
            kind: CalendarEventKind.medication,
            sourceId: medication.id,
            petId: medication.petId,
            petName: petName,
            title: medication.name,
            subtitle: medication.dosage,
            dateTime: doses.first,
            doseTimes: doses,
            status: status,
          ),
    ];
  }

  /// A snapshot containing only [petId]'s events.
  CalendarSnapshot forPet(String petId) => CalendarSnapshot(
        datedEvents: [
          for (final list in _byDay.values)
            for (final e in list)
              if (e.petId == petId) e,
        ],
        medications: [
          for (final m in medications)
            if (m.medication.petId == petId) m,
        ],
        now: now,
      );
}
