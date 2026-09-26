import 'package:meta/meta.dart';

/// A time of day for a dose (framework-free alternative to `TimeOfDay`).
@immutable
class DoseTime implements Comparable<DoseTime> {
  const DoseTime(this.hour, this.minute)
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  /// Parses `"08:30"`; returns `null` for malformed input.
  static DoseTime? tryParse(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    if (h > 23 || m > 59) return null;
    return DoseTime(h, m);
  }

  final int hour;
  final int minute;

  /// `"08:30"` — the storage format.
  String get hhmm => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  DateTime on(DateTime day) => DateTime(day.year, day.month, day.day, hour, minute);

  @override
  int compareTo(DoseTime other) => (hour * 60 + minute).compareTo(other.hour * 60 + other.minute);

  @override
  bool operator ==(Object other) => other is DoseTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => hhmm;
}
