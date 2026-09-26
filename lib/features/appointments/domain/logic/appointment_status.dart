import '../../../../core/utils/date_utils.dart';
import '../entities/appointment.dart';
import '../entities/appointment_overview.dart';

AppointmentDisplayStatus appointmentDisplayStatus(Appointment a, DateTime now) {
  switch (a.status) {
    case AppointmentStatus.cancelled:
      return AppointmentDisplayStatus.cancelled;
    case AppointmentStatus.completed:
      return AppointmentDisplayStatus.completed;
    case AppointmentStatus.scheduled:
      if (a.dateTime.isBefore(now)) return AppointmentDisplayStatus.past;
      if (daysBetween(now, a.dateTime) == 0) return AppointmentDisplayStatus.today;
      return AppointmentDisplayStatus.upcoming;
  }
}

AppointmentOverview buildAppointmentOverview(List<Appointment> all, DateTime now) {
  if (all.isEmpty) return AppointmentOverview.empty;

  final upcoming = <AppointmentEntry>[];
  final history = <AppointmentEntry>[];
  for (final a in all) {
    final status = appointmentDisplayStatus(a, now);
    final entry = AppointmentEntry(a, status);
    if (status == AppointmentDisplayStatus.upcoming || status == AppointmentDisplayStatus.today) {
      upcoming.add(entry);
    } else {
      history.add(entry);
    }
  }
  upcoming.sort((a, b) => a.appointment.dateTime.compareTo(b.appointment.dateTime));
  history.sort((a, b) {
    // Items needing an update float to the top of history.
    final aNeeds = a.status == AppointmentDisplayStatus.past;
    final bNeeds = b.status == AppointmentDisplayStatus.past;
    if (aNeeds != bNeeds) return aNeeds ? -1 : 1;
    return b.appointment.dateTime.compareTo(a.appointment.dateTime);
  });
  return AppointmentOverview(upcoming: upcoming, history: history);
}
