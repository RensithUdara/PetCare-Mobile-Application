import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/logic/weight_trend.dart';
import '../providers/weight_providers.dart';

/// "12.5" or "12" (drops a trailing ".0").
String kg(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// "+0.6 kg", "−1.2 kg", "±0 kg".
String signedKg(double v) => v == 0 ? '±0 kg' : '${v > 0 ? '+' : '−'}${kg(v.abs())} kg';

/// Weight over time. X axis = days since the first plotted entry.
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries});

  /// Oldest first; at least one entry.
  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final start = entries.first.date;
    double x(WeightEntry e) => e.date.difference(start).inHours / 24;

    final spots = [for (final e in entries) FlSpot(x(e), e.weightKg)];
    final minY = entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    final maxY = entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    // Pad the Y range so a flat line isn't glued to an edge.
    final pad = ((maxY - minY) * 0.2).clamp(0.5, double.infinity);
    final maxX = spots.last.x == 0 ? 1.0 : spots.last.x;
    final dateFmt = DateFormat.MMMd();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: (minY - pad).clamp(0, double.infinity),
        maxY: maxY + pad,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => value == meta.min || value == meta.max
                  ? const SizedBox.shrink()
                  : Text(kg(value), style: theme.textTheme.labelSmall),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxX / 3 < 1 ? 1 : maxX / 3,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  dateFmt.format(start.add(Duration(hours: (value * 24).round()))),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${kg(s.y)} kg\n${dateFmt.format(entries[s.spotIndex].date)}',
                  TextStyle(color: scheme.onInverseSurface, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: spots.length > 2,
            preventCurveOverShooting: true,
            color: scheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: spots.length <= 24),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Current weight with change since the previous weigh-in.
class WeightSummaryCard extends StatelessWidget {
  const WeightSummaryCard({super.key, required this.summary});

  final WeightSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = summary.changeKg;
    final colors = StatusColors.of(context);
    final changeColor = change == null || change == 0
        ? theme.colorScheme.onSurfaceVariant
        : change > 0
            ? colors.info
            : colors.warning;

    Widget stat(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${kg(summary.latest.weightKg)} kg',
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
            Text('as of ${DateFormat.yMMMd().format(summary.latest.date)}',
                style: theme.textTheme.bodySmall),
            if (change != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    change > 0 ? Icons.trending_up : change < 0 ? Icons.trending_down : Icons.trending_flat,
                    color: changeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${signedKg(change)} (${summary.changePercent! >= 0 ? '+' : ''}'
                    '${summary.changePercent!.toStringAsFixed(1)}%) since '
                    '${DateFormat.MMMd().format(summary.previous!.date)}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: changeColor),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                stat('Lowest', '${kg(summary.minKg)} kg'),
                stat('Highest', '${kg(summary.maxKg)} kg'),
                stat('Entries', '${summary.count}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary row on the pet profile linking to the weight screen.
class PetWeightTile extends ConsumerWidget {
  const PetWeightTile({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(petWeightsProvider(petId)).value;
    final summary = entries == null ? null : summarize(entries);
    final String subtitle;
    if (entries == null) {
      subtitle = 'Loading…';
    } else if (summary == null) {
      subtitle = 'No weigh-ins yet';
    } else {
      final change = summary.changeKg;
      subtitle = '${kg(summary.latest.weightKg)} kg'
          '${change == null ? '' : ' · ${signedKg(change)} since last'}';
    }
    return ListTile(
      leading: const Icon(Icons.monitor_weight_outlined),
      title: const Text('Weight'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(AppRoutes.weight(petId)),
    );
  }
}
