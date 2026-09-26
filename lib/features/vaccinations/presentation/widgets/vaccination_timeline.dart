import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/vaccination_overview.dart';
import 'vaccination_status_badge.dart';

/// Vaccination history grouped by year:
///
/// ```text
/// 2026
/// │
/// ├── Rabies        Upcoming
/// 2025
/// ├── Rabies        Completed
/// └── DHPP          Up to date
/// ```
class VaccinationTimeline extends StatelessWidget {
  const VaccinationTimeline({
    super.key,
    required this.historyByYear,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  });

  final List<(int year, List<VaccinationEntry> entries)> historyByYear;
  final ValueChanged<VaccinationEntry> onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // Flatten into rows so the list stays lazily built for long histories.
    final rows = <Object>[];
    for (final (year, entries) in historyByYear) {
      rows.add(year);
      for (var i = 0; i < entries.length; i++) {
        rows.add((entries[i], i == entries.length - 1));
      }
    }

    return ListView.builder(
      padding: padding,
      itemCount: rows.length,
      itemBuilder: (context, i) => switch (rows[i]) {
        int year => _YearHeader(year: year, isFirst: i == 0),
        (VaccinationEntry entry, bool isLast) =>
          _TimelineRow(entry: entry, isLast: isLast, onTap: () => onTap(entry)),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _YearHeader extends StatelessWidget {
  const _YearHeader({required this.year, required this.isFirst});

  final int year;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 20, bottom: 4),
      child: Text(
        '$year',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast, required this.onTap});

  final VaccinationEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  static const _railWidth = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = entry.vaccination;
    final lineColor = theme.colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _railWidth,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical rail; stops at the dot for the last item.
                Positioned(
                  top: 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 26 : null,
                  child: Container(width: 2, color: lineColor),
                ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.status.color(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 4, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.vaccineName, style: theme.textTheme.titleSmall),
                          Text(
                            DateFormat.yMMMd().format(v.dateAdministered),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    VaccinationStatusBadge(status: entry.status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
