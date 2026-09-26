import '../../../../core/utils/clock.dart';

/// "Due today", "Due tomorrow", "Due in 12 days", "Overdue by 3 days".
String dueLabel(DateTime due, DateTime now) {
  final days = daysBetween(now, due);
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  if (days > 1) return 'Due in $days days';
  if (days == -1) return 'Overdue by 1 day';
  return 'Overdue by ${-days} days';
}
