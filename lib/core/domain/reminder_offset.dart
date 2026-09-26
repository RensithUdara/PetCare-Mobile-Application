/// How long before a due date a reminder fires. `null` (no offset) means
/// the reminder is disabled.
enum ReminderOffset {
  onTheDay(0, 'On the day'),
  oneDay(1, '1 day before'),
  threeDays(3, '3 days before'),
  sevenDays(7, '7 days before'),
  fourteenDays(14, '14 days before');

  const ReminderOffset(this.days, this.label);

  final int days;
  final String label;

  /// Reminder moment for [due], at 9:00 on the reminder day.
  DateTime reminderDateFor(DateTime due) {
    final day = DateTime(due.year, due.month, due.day).subtract(Duration(days: days));
    return DateTime(day.year, day.month, day.day, 9);
  }

  static ReminderOffset? fromDays(int? days) {
    if (days == null) return null;
    for (final offset in values) {
      if (offset.days == days) return offset;
    }
    return null;
  }
}
