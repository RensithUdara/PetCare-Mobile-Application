import 'package:meta/meta.dart';

enum ReminderCategory {
  vaccination('Vaccination reminders'),
  appointment('Appointment reminders'),
  medication('Medication reminders');

  const ReminderCategory(this.label);
  final String label;
}

/// Identifies the record a notification is about. Encoded into the
/// notification payload so a tap can open the right screen.
@immutable
class ReminderTarget {
  const ReminderTarget(this.category, this.sourceId);

  /// Parses `"vaccination:abc123"`; returns `null` for anything else.
  static ReminderTarget? tryParse(String? payload) {
    if (payload == null) return null;
    final i = payload.indexOf(':');
    if (i <= 0 || i == payload.length - 1) return null;
    final category = ReminderCategory.values.asNameMap()[payload.substring(0, i)];
    return category == null ? null : ReminderTarget(category, payload.substring(i + 1));
  }

  final ReminderCategory category;
  final String sourceId;

  String get payload => '${category.name}:$sourceId';

  @override
  bool operator ==(Object other) =>
      other is ReminderTarget && other.category == category && other.sourceId == sourceId;

  @override
  int get hashCode => Object.hash(category, sourceId);

  @override
  String toString() => payload;
}

/// A notification to schedule on the device.
@immutable
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.target,
    required this.title,
    required this.body,
    required this.fireAt,
  });

  /// Stable 31-bit id (Android notification ids are 32-bit signed ints).
  final int id;
  final ReminderTarget target;
  final String title;
  final String body;
  final DateTime fireAt;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.target == target &&
      other.title == title &&
      other.body == body &&
      other.fireAt == fireAt;

  @override
  int get hashCode => Object.hash(id, target, title, body, fireAt);

  @override
  String toString() => 'PlannedReminder($target @ $fireAt: $body)';
}
