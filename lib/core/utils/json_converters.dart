import 'package:json_annotation/json_annotation.dart';

/// Reads dates stored as [DateTime], ISO strings or epoch millis, and writes
/// them back as [DateTime] (Firestore persists those as Timestamps).
///
/// Repositories convert Firestore `Timestamp`s to [DateTime] before calling
/// `fromJson`, so domain models never depend on Firebase types.
class NullableDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) => switch (json) {
        DateTime d => d,
        String s => DateTime.tryParse(s),
        int ms => DateTime.fromMillisecondsSinceEpoch(ms),
        _ => null,
      };

  @override
  Object? toJson(DateTime? date) => date;
}
