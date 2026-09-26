import 'package:meta/meta.dart';

import 'appointment.dart';

/// What the UI shows for an appointment at a given moment.
enum AppointmentDisplayStatus {
  upcoming('Upcoming'),
  today('Today'),

  /// Still `scheduled` but the time has passed — the owner should mark it
  /// completed or cancelled.
  past('Needs update'),
  completed('Completed'),
  cancelled('Cancelled');

  const AppointmentDisplayStatus(this.label);
  final String label;
}

@immutable
class AppointmentEntry {
  const AppointmentEntry(this.appointment, this.status);

  final Appointment appointment;
  final AppointmentDisplayStatus status;

  @override
  bool operator ==(Object other) =>
      other is AppointmentEntry && other.appointment == appointment && other.status == status;

  @override
  int get hashCode => Object.hash(appointment, status);
}

/// A pet's appointments split into what's coming and what's done.
@immutable
class AppointmentOverview {
  const AppointmentOverview({required this.upcoming, required this.history});

  static const empty = AppointmentOverview(upcoming: [], history: []);

  /// Scheduled and not yet started, soonest first.
  final List<AppointmentEntry> upcoming;

  /// Everything else (past, completed, cancelled), most recent first.
  final List<AppointmentEntry> history;

  int get total => upcoming.length + history.length;

  AppointmentEntry? get next => upcoming.isEmpty ? null : upcoming.first;

  int count(AppointmentDisplayStatus status) =>
      [...upcoming, ...history].where((e) => e.status == status).length;
}
