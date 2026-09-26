import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_overview.dart';
import 'appointment_status_badge.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.entry, this.onTap});

  final AppointmentEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = entry.appointment;
    final color = entry.status.color(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final cancelled = a.status == AppointmentStatus.cancelled;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _DateBlock(date: a.dateTime, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(a.type.icon, size: 18, color: color),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            a.type.label,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: cancelled ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(DateFormat.jm().format(a.dateTime), style: muted),
                    if (a.clinic != null || a.reason != null)
                      Text(
                        a.reason ?? a.clinic!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: muted,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppointmentStatusBadge(status: entry.status),
            ],
          ),
        ),
      ),
    );
  }
}

/// "OCT / 25" calendar-style date block.
class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.date, required this.color});

  final DateTime date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            DateFormat.MMM().format(date).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
          Text(
            '${date.day}',
            style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
