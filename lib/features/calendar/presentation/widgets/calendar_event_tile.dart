import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/calendar_event.dart';

extension CalendarEventStyle on CalendarEvent {
  IconData get icon => switch (kind) {
        CalendarEventKind.appointment => Icons.medical_services_outlined,
        CalendarEventKind.vaccinationDue => Icons.vaccines_outlined,
        CalendarEventKind.medication => Icons.medication_outlined,
      };

  StatusTone get tone => switch (status) {
        CalendarEventStatus.upcoming => switch (kind) {
            CalendarEventKind.appointment => StatusTone.info,
            CalendarEventKind.vaccinationDue => StatusTone.success,
            CalendarEventKind.medication => StatusTone.neutral,
          },
        CalendarEventStatus.today => StatusTone.warning,
        CalendarEventStatus.overdue || CalendarEventStatus.needsUpdate => StatusTone.danger,
        CalendarEventStatus.completed =>
          kind == CalendarEventKind.medication ? StatusTone.neutral : StatusTone.success,
        CalendarEventStatus.cancelled => StatusTone.neutral,
      };

  String? get statusLabel => switch (status) {
        CalendarEventStatus.overdue => 'Overdue',
        CalendarEventStatus.needsUpdate => 'Needs update',
        CalendarEventStatus.completed => kind == CalendarEventKind.medication ? null : 'Completed',
        CalendarEventStatus.cancelled => 'Cancelled',
        CalendarEventStatus.today => 'Today',
        CalendarEventStatus.upcoming => null,
      };
}

/// Where tapping [event] leads, staying inside the current tab.
String eventDetailsRoute(CalendarEvent event, {required bool fromHome}) =>
    switch (event.kind) {
      CalendarEventKind.appointment => fromHome
          ? AppRoutes.homeAppointment(event.sourceId)
          : AppRoutes.calendarAppointment(event.sourceId),
      CalendarEventKind.vaccinationDue => fromHome
          ? AppRoutes.homeVaccination(event.sourceId)
          : AppRoutes.calendarVaccination(event.sourceId),
      CalendarEventKind.medication => fromHome
          ? AppRoutes.homeMedication(event.sourceId)
          : AppRoutes.calendarMedication(event.sourceId),
    };

/// "💉 Bruno · Rabies due" / "🩺 Milo · Routine checkup · 10:30 AM"
class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({super.key, required this.event, this.onTap, this.showDate = false});

  final CalendarEvent event;
  final VoidCallback? onTap;

  /// Prefix the time with the date (for lists spanning several days).
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = event.tone.colorOf(context);
    final time = event.isAllDay
        ? 'All day'
        : event.doseTimes.isNotEmpty
            ? event.doseTimes.map(DateFormat.jm().format).join(', ')
            : DateFormat.jm().format(event.dateTime);
    final label = event.statusLabel;
    final when = showDate ? '${DateFormat.MMMEd().format(event.dateTime)} · $time' : time;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(event.icon, color: color),
        ),
        title: Text(
          '${event.petName} · ${event.title}',
          style: event.status == CalendarEventStatus.cancelled
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(
          [when, ?event.subtitle].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: label == null
            ? const Icon(Icons.chevron_right)
            : StatusBadge(label: label, tone: event.tone),
        titleTextStyle: theme.textTheme.titleSmall,
      ),
    );
  }
}
