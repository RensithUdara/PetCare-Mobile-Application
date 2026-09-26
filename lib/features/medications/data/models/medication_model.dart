import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/dose_time.dart';
import '../../domain/entities/medication.dart';

part 'medication_model.g.dart';

/// Firestore representation of a [Medication]
/// (`users/{uid}/medications/{id}`). Dose times are stored as `"HH:mm"`.
@JsonSerializable(includeIfNull: true)
class MedicationModel {
  const MedicationModel({
    this.id = '',
    required this.ownerId,
    required this.petId,
    required this.name,
    required this.dosage,
    this.frequency,
    required this.startDate,
    this.endDate,
    this.doseTimes = const [],
    this.remindersEnabled = true,
    this.instructions,
    this.veterinarian,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) => _$MedicationModelFromJson(json);

  factory MedicationModel.fromEntity(Medication m) => MedicationModel(
        id: m.id,
        ownerId: m.ownerId,
        petId: m.petId,
        name: m.name,
        dosage: m.dosage,
        frequency: m.frequency.name,
        startDate: m.startDate,
        endDate: m.endDate,
        doseTimes: [for (final t in m.doseTimes) t.hhmm],
        remindersEnabled: m.remindersEnabled,
        instructions: m.instructions,
        veterinarian: m.veterinarian,
        notes: m.notes,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );

  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String petId;
  final String name;
  final String dosage;
  final String? frequency;
  @NullableDateTimeConverter()
  final DateTime? startDate;
  @NullableDateTimeConverter()
  final DateTime? endDate;
  final List<String> doseTimes;
  final bool remindersEnabled;
  final String? instructions;
  final String? veterinarian;
  final String? notes;
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$MedicationModelToJson(this);

  Medication toEntity() => Medication(
        id: id,
        ownerId: ownerId,
        petId: petId,
        name: name,
        dosage: dosage,
        frequency:
            MedicationFrequency.values.asNameMap()[frequency] ?? MedicationFrequency.onceDaily,
        startDate: startDate ?? createdAt ?? DateTime(1970),
        endDate: endDate,
        doseTimes: [
          for (final s in doseTimes)
            if (DoseTime.tryParse(s) case final t?) t,
        ]..sort(),
        remindersEnabled: remindersEnabled,
        instructions: instructions,
        veterinarian: veterinarian,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
