import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../pets/presentation/widgets/pet_avatar.dart';
import '../../domain/entities/dashboard.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

extension HealthAlertPresentation on HealthAlert {
  StatusTone get tone => switch (kind) {
        HealthAlertKind.vaccinationOverdue => StatusTone.danger,
        HealthAlertKind.appointmentNeedsUpdate => StatusTone.warning,
      };

  IconData get icon => switch (kind) {
        HealthAlertKind.vaccinationOverdue => Icons.vaccines_outlined,
        HealthAlertKind.appointmentNeedsUpdate => Icons.event_busy_outlined,
      };

  String message(DateTime now) => switch (kind) {
        HealthAlertKind.vaccinationOverdue =>
          '$title vaccination is overdue by ${daysBetween(date, now)} '
              'day${daysBetween(date, now) == 1 ? '' : 's'}',
        HealthAlertKind.appointmentNeedsUpdate =>
          '$title on ${DateFormat.MMMd().format(date)} — did it happen?',
      };

  String get route => switch (kind) {
        HealthAlertKind.vaccinationOverdue => AppRoutes.homeVaccination(sourceId),
        HealthAlertKind.appointmentNeedsUpdate => AppRoutes.homeAppointment(sourceId),
      };
}

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, required this.now, this.onTap});

  final HealthAlert alert;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = alert.tone.colorOf(context);
    return Card(
      color: color.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(alert.icon, color: color),
        title: Text(alert.petName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(alert.message(now)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Compact pet tile for the horizontal "Your pets" strip.
class PetSummaryCard extends StatelessWidget {
  const PetSummaryCard({super.key, required this.summary, this.onTap});

  final PetSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = summary.nextEvent;
    final String line;
    if (summary.alertCount > 0) {
      line = '${summary.alertCount} alert${summary.alertCount == 1 ? '' : 's'}';
    } else if (next != null) {
      line = '${next.kind == CalendarEventKind.vaccinationDue ? '💉' : '🩺'} '
          '${DateFormat.MMMd().format(next.dateTime)}';
    } else {
      line = 'All good';
    }

    return SizedBox(
      width: 120,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Badge(
                  isLabelVisible: summary.alertCount > 0,
                  label: Text('${summary.alertCount}'),
                  child: PetAvatar.fromPet(summary.pet, radius: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  summary.pet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: summary.alertCount > 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddPetCard extends StatelessWidget {
  const AddPetCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 120,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.add, color: scheme.primary),
              ),
              const SizedBox(height: 8),
              const Text('Add pet'),
            ],
          ),
        ),
      ),
    );
  }
}

extension ActivityPresentation on ActivityItem {
  IconData get icon => switch (kind) {
        ActivityKind.vaccinationGiven => Icons.vaccines_outlined,
        ActivityKind.appointmentCompleted => Icons.check_circle_outline,
        ActivityKind.medicationStarted => Icons.medication_outlined,
      };

  String get description => switch (kind) {
        ActivityKind.vaccinationGiven => '$title vaccination given',
        ActivityKind.appointmentCompleted => '$title completed',
        ActivityKind.medicationStarted => 'Started $title',
      };

  String get route => switch (kind) {
        ActivityKind.vaccinationGiven => AppRoutes.homeVaccination(sourceId),
        ActivityKind.appointmentCompleted => AppRoutes.homeAppointment(sourceId),
        ActivityKind.medicationStarted => AppRoutes.homeMedication(sourceId),
      };
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.item, this.onTap});

  final ActivityItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
      title: Text(item.description),
      subtitle: Text('${item.petName} · ${DateFormat.MMMd().format(item.date)}'),
    );
  }
}
