import 'package:meta/meta.dart';

enum CalendarEventKind { appointment, vaccinationDue, medication }

/// Unified status across event kinds, for colouring and filtering.
enum CalendarEventStatus { upcoming, today, overdue, needsUpdate, completed, cancelled }

/// Anything that belongs on the calendar: a vet appointment, a vaccination
/// due date, or a day's doses of a medication.
@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.kind,
    required this.sourceId,
    required this.petId,
    required this.petName,
    required this.title,
    required this.dateTime,
    required this.status,
    this.isAllDay = false,
    this.subtitle,
    this.doseTimes = const [],
  });

  final CalendarEventKind kind;

  /// Id of the underlying appointment / vaccination.
  final String sourceId;
  final String petId;
  final String petName;
  final String title;
  final String? subtitle;
  final DateTime dateTime;

  /// Vaccination due dates have no time of day.
  final bool isAllDay;
  final CalendarEventStatus status;

  /// For medication events: every dose moment on that day.
  final List<DateTime> doseTimes;

  @override
  bool operator ==(Object other) =>
      other is CalendarEvent &&
      other.kind == kind &&
      other.sourceId == sourceId &&
      other.petId == petId &&
      other.petName == petName &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.dateTime == dateTime &&
      other.isAllDay == isAllDay &&
      other.status == status &&
      _listEquals(other.doseTimes, doseTimes);

  static bool _listEquals(List<DateTime> a, List<DateTime> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(kind, sourceId, petId, petName, title, subtitle, dateTime, isAllDay, status,
          Object.hashAll(doseTimes));
}
