import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_entry.freezed.dart';

/// One weigh-in for a pet.
@freezed
abstract class WeightEntry with _$WeightEntry {
  const WeightEntry._();

  const factory WeightEntry({
    @Default('') String id,
    required String ownerId,
    required String petId,

    /// Date only.
    required DateTime date,
    required double weightKg,
    String? note,
    DateTime? createdAt,
  }) = _WeightEntry;

  bool get isNew => id.isEmpty;
}
