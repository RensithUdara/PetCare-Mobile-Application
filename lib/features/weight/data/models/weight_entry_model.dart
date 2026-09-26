import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/weight_entry.dart';

part 'weight_entry_model.g.dart';

/// Firestore representation of a [WeightEntry] (`users/{uid}/weights/{id}`).
@JsonSerializable(includeIfNull: true)
class WeightEntryModel {
  const WeightEntryModel({
    this.id = '',
    required this.ownerId,
    required this.petId,
    required this.date,
    required this.weightKg,
    this.note,
    this.createdAt,
  });

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) => _$WeightEntryModelFromJson(json);

  factory WeightEntryModel.fromEntity(WeightEntry e) => WeightEntryModel(
        id: e.id,
        ownerId: e.ownerId,
        petId: e.petId,
        date: e.date,
        weightKg: e.weightKg,
        note: e.note,
        createdAt: e.createdAt,
      );

  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String petId;
  @NullableDateTimeConverter()
  final DateTime? date;
  final double weightKg;
  final String? note;
  @NullableDateTimeConverter()
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$WeightEntryModelToJson(this);

  WeightEntry toEntity() => WeightEntry(
        id: id,
        ownerId: ownerId,
        petId: petId,
        date: date ?? createdAt ?? DateTime(1970),
        weightKg: weightKg,
        note: note,
        createdAt: createdAt,
      );
}
