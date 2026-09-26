import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/dose_time.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/medication_overview.dart';
import '../../domain/logic/medication_schedule.dart';
import '../../../sync/presentation/widgets/sync_widgets.dart';
import '../providers/medication_providers.dart';

extension MedicationStatusStyle on MedicationStatus {
  StatusTone get tone => switch (this) {
        MedicationStatus.upcoming => StatusTone.info,
        MedicationStatus.active => StatusTone.success,
        MedicationStatus.completed => StatusTone.neutral,
      };
}

extension DoseTimeFormat on DoseTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  String format(BuildContext context) => toTimeOfDay().format(context);
}

extension TimeOfDayToDose on TimeOfDay {
  DoseTime toDoseTime() => DoseTime(hour, minute);
}

/// "Once daily · 8:00 AM, 8:00 PM" or "As needed".
String scheduleLabel(BuildContext context, Medication m) {
  if (!m.frequency.isScheduled || m.doseTimes.isEmpty) return m.frequency.label;
  return '${m.frequency.label} · ${m.doseTimes.map((t) => t.format(context)).join(', ')}';
}

/// "Today at 8:00 PM", "Tomorrow at 8:00 AM", "Oct 3 at 8:00 AM".
String nextDoseLabel(DateTime dose, DateTime now) {
  final time = DateFormat.jm().format(dose);
  return switch (daysBetween(now, dose)) {
    0 => 'Today at $time',
    1 => 'Tomorrow at $time',
    _ => '${DateFormat.MMMd().format(dose)} at $time',
  };
}

class MedicationCard extends StatelessWidget {
  const MedicationCard({super.key, required this.entry, required this.now, this.onTap});

  final MedicationEntry entry;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = entry.medication;
    final color = entry.status.tone.colorOf(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final progress = courseProgress(m, now);
    final date = DateFormat.MMMd();

    final detail = switch (entry.status) {
      MedicationStatus.active => entry.nextDose == null
          ? scheduleLabel(context, m)
          : 'Next: ${nextDoseLabel(entry.nextDose!, now)}',
      MedicationStatus.upcoming => 'Starts ${date.format(m.startDate)}',
      MedicationStatus.completed => 'Ended ${date.format(m.endDate!)}',
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.14),
                    child: Icon(Icons.medication_outlined, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        PendingSyncBadge(id: m.id),
                        Text('${m.dosage} · ${m.frequency.label}', style: muted),
                        Text(detail, style: muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(label: entry.status.label, tone: entry.status.tone),
                ],
              ),
              if (progress != null && entry.status == MedicationStatus.active) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress.fraction, minHeight: 6),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day ${progress.day} of ${progress.totalDays}',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Summary row on the pet profile linking to the medications screen.
class PetMedicationsTile extends ConsumerWidget {
  const PetMedicationsTile({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(petMedicationOverviewProvider(petId)).value;

    final String subtitle;
    if (overview == null) {
      subtitle = 'Loading…';
    } else if (overview.total == 0) {
      subtitle = 'No medications';
    } else if (overview.active.isEmpty) {
      subtitle = 'None active · ${overview.total} total';
    } else {
      final active = '${overview.active.length} active';
      final next = overview.nextDose;
      subtitle = next == null
          ? active
          : '$active · Next: ${next.medication.name} ${DateFormat.jm().format(next.nextDose!)}';
    }

    return ListTile(
      leading: const Icon(Icons.medication_outlined),
      title: const Text('Medications'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(AppRoutes.medications(petId)),
    );
  }
}
