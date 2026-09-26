// Pure date helpers (no Flutter / Riverpod) usable from the domain layer.

/// Strips the time component.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole calendar days from [from] to [to] (negative if [to] is earlier).
/// Computed in UTC so daylight-saving shifts can't skew the result.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(to.year, to.month, to.day)
    .difference(DateTime.utc(from.year, from.month, from.day))
    .inDays;
