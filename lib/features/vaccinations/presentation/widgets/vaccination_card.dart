import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/vaccination_overview.dart';
import '../../../sync/presentation/widgets/sync_widgets.dart';
import 'vaccination_formatters.dart';
import 'vaccination_status_badge.dart';

class VaccinationCard extends StatelessWidget {
  const VaccinationCard({
    super.key,
    required this.entry,
    required this.now,
    this.onTap,
  });

  final VaccinationEntry entry;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = entry.vaccination;
    final date = DateFormat.yMMMd();
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final showCountdown = v.nextDueDate != null && entry.status != VaccinationStatus.completed;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: entry.status.color(context).withValues(alpha: 0.14),
                child: Icon(Icons.vaccines, color: entry.status.color(context)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.vaccineName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    PendingSyncBadge(id: v.id),
                    const SizedBox(height: 2),
                    Text('Given ${date.format(v.dateAdministered)}', style: muted),
                    if (showCountdown)
                      Text(
                        '${dueLabel(v.nextDueDate!, now)} · ${date.format(v.nextDueDate!)}',
                        style: muted?.copyWith(
                          color: entry.status == VaccinationStatus.upToDate
                              ? null
                              : entry.status.color(context),
                          fontWeight: entry.status == VaccinationStatus.upToDate
                              ? null
                              : FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VaccinationStatusBadge(status: entry.status),
            ],
          ),
        ),
      ),
    );
  }
}
