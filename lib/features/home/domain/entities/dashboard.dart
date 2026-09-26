import 'package:meta/meta.dart';

import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../pets/domain/entities/pet.dart';

enum HealthAlertKind {
  /// A vaccine's latest dose is past its due date.
  vaccinationOverdue,

  /// A scheduled appointment's time has passed without an update.
  appointmentNeedsUpdate,
}

/// Something the owner should act on.
@immutable
class HealthAlert {
  const HealthAlert({
    required this.kind,
    required this.sourceId,
    required this.petId,
    required this.petName,
    required this.title,
    required this.date,
  });

  final HealthAlertKind kind;
  final String sourceId;
  final String petId;
  final String petName;

  /// e.g. "Rabies" or "Routine checkup".
  final String title;

  /// Due date / appointment time the alert refers to.
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is HealthAlert &&
      other.kind == kind &&
      other.sourceId == sourceId &&
      other.petId == petId &&
      other.petName == petName &&
      other.title == title &&
      other.date == date;

  @override
  int get hashCode => Object.hash(kind, sourceId, petId, petName, title, date);
}

enum ActivityKind { vaccinationGiven, appointmentCompleted, medicationStarted }

/// A recent health event, for the "Recent activity" feed.
@immutable
class ActivityItem {
  const ActivityItem({
    required this.kind,
    required this.sourceId,
    required this.petId,
    required this.petName,
    required this.title,
    required this.date,
  });

  final ActivityKind kind;
  final String sourceId;
  final String petId;
  final String petName;
  final String title;
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is ActivityItem &&
      other.kind == kind &&
      other.sourceId == sourceId &&
      other.petId == petId &&
      other.petName == petName &&
      other.title == title &&
      other.date == date;

  @override
  int get hashCode => Object.hash(kind, sourceId, petId, petName, title, date);
}

/// Per-pet line on the dashboard.
@immutable
class PetSummary {
  const PetSummary({
    required this.pet,
    required this.alertCount,
    required this.activeMedications,
    this.nextEvent,
  });

  final Pet pet;
  final int alertCount;
  final int activeMedications;

  /// Next upcoming appointment or vaccination due date, if any.
  final CalendarEvent? nextEvent;

  @override
  bool operator ==(Object other) =>
      other is PetSummary &&
      other.pet == pet &&
      other.alertCount == alertCount &&
      other.activeMedications == activeMedications &&
      other.nextEvent == nextEvent;

  @override
  int get hashCode => Object.hash(pet, alertCount, activeMedications, nextEvent);
}

/// Everything the home screen shows.
@immutable
class Dashboard {
  const Dashboard({
    required this.pets,
    required this.alerts,
    required this.todaysDoses,
    required this.upcoming,
    required this.recentActivity,
  });

  static const empty =
      Dashboard(pets: [], alerts: [], todaysDoses: [], upcoming: [], recentActivity: []);

  final List<PetSummary> pets;

  /// Most urgent first.
  final List<HealthAlert> alerts;

  /// Medication events for today (one per medication, with dose times).
  final List<CalendarEvent> todaysDoses;

  /// Appointments and vaccination due dates in the coming window, soonest
  /// first (medications excluded — see [todaysDoses]).
  final List<CalendarEvent> upcoming;

  /// Newest first.
  final List<ActivityItem> recentActivity;

  bool get hasPets => pets.isNotEmpty;
}
