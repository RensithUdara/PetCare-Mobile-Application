/// Human-readable age such as "3 years old", "5 months old", "2 weeks old".
/// Returns `null` when [dateOfBirth] is unknown or in the future.
String? petAgeLabel(DateTime? dateOfBirth, DateTime now) {
  if (dateOfBirth == null) return null;
  final dob = DateTime(dateOfBirth.year, dateOfBirth.month, dateOfBirth.day);
  final today = DateTime(now.year, now.month, now.day);
  if (dob.isAfter(today)) return null;

  var months = (today.year - dob.year) * 12 + today.month - dob.month;
  if (today.day < dob.day) months--;

  String plural(int n, String unit) => '$n $unit${n == 1 ? '' : 's'} old';

  if (months >= 12) return plural(months ~/ 12, 'year');
  if (months >= 1) return plural(months, 'month');

  final days = today.difference(dob).inDays;
  if (days >= 7) return plural(days ~/ 7, 'week');
  return days == 0 ? 'Born today' : plural(days, 'day');
}
