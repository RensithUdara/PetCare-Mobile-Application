import 'package:meta/meta.dart';

import '../../../../core/utils/date_utils.dart';
import '../entities/weight_entry.dart';

enum WeightRange {
  month('1M', 30),
  quarter('3M', 91),
  halfYear('6M', 182),
  year('1Y', 365),
  all('All', null);

  const WeightRange(this.label, this.days);
  final String label;

  /// `null` = no limit.
  final int? days;
}

/// Sorts entries oldest → newest (same day: most recently created last).
List<WeightEntry> sortByDate(Iterable<WeightEntry> entries) => [...entries]..sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    return (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0));
  });

/// Entries within [range] of [now], oldest first.
List<WeightEntry> entriesInRange(List<WeightEntry> sorted, WeightRange range, DateTime now) {
  final days = range.days;
  if (days == null) return sorted;
  final from = dateOnly(now).subtract(Duration(days: days));
  return sorted.where((e) => !dateOnly(e.date).isBefore(from)).toList();
}

/// Headline numbers for the weight screen and pet profile.
@immutable
class WeightSummary {
  const WeightSummary({
    required this.latest,
    this.previous,
    required this.minKg,
    required this.maxKg,
    required this.count,
  });

  final WeightEntry latest;
  final WeightEntry? previous;
  final double minKg;
  final double maxKg;
  final int count;

  /// Change since the previous entry (kg), `null` with a single entry.
  double? get changeKg => previous == null ? null : _round(latest.weightKg - previous!.weightKg);

  /// Change since the previous entry as a percentage.
  double? get changePercent =>
      previous == null || previous!.weightKg == 0
          ? null
          : _round((latest.weightKg - previous!.weightKg) / previous!.weightKg * 100);

  static double _round(double v) => (v * 10).round() / 10;
}

/// `null` when there are no entries. [sorted] must be oldest first.
WeightSummary? summarize(List<WeightEntry> sorted) {
  if (sorted.isEmpty) return null;
  final weights = sorted.map((e) => e.weightKg);
  return WeightSummary(
    latest: sorted.last,
    previous: sorted.length > 1 ? sorted[sorted.length - 2] : null,
    minKg: weights.reduce((a, b) => a < b ? a : b),
    maxKg: weights.reduce((a, b) => a > b ? a : b),
    count: sorted.length,
  );
}
