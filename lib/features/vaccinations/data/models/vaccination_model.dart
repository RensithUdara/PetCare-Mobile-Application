import 'package:json_annotation/json_annotation.dart';

import '../../../../core/domain/reminder_offset.dart';
import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/vaccination.dart';

part 'vaccination_model.g.dart';

/// Firestore representation of a [Vaccination]
/// (`users/{uid}/vaccinations/{id}`).
@JsonSerializable(includeIfNull: true)
class VaccinationModel {
  const VaccinationModel({
    this.id = '',
    required this.ownerId,
    required this.petId,
    required this.vaccineName,
    this.category,
    required this.dateAdministered,
    this.nextDueDate,
    this.veterinarian,
    this.clinic,
    this.batchNumber,
    this.notes,
    this.reminderDaysBefore,
    this.reminderAt,
    this.certificateUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) =>
      _$VaccinationModelFromJson(json);

  factory VaccinationModel.fromEntity(Vaccination v) => VaccinationModel(
        id: v.id,
        ownerId: v.ownerId,
        petId: v.petId,
        vaccineName: v.vaccineName,
        category: v.category.name,
        dateAdministered: v.dateAdministered,
        nextDueDate: v.nextDueDate,
        veterinarian: v.veterinarian,
        clinic: v.clinic,
        batchNumber: v.batchNumber,
        notes: v.notes,
        reminderDaysBefore: v.reminder?.days,
        reminderAt: v.reminderDate,
        certificateUrl: v.certificateUrl,
        createdAt: v.createdAt,
        updatedAt: v.updatedAt,
      );

  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String petId;
  final String vaccineName;
  final String? category;
  @NullableDateTimeConverter()
  final DateTime? dateAdministered;
  @NullableDateTimeConverter()
  final DateTime? nextDueDate;
  final String? veterinarian;
  final String? clinic;
  final String? batchNumber;
  final String? notes;
  final int? reminderDaysBefore;

  /// Denormalized reminder moment so Cloud Functions can query
  /// `reminderAt <= now` without recomputing it.
  @NullableDateTimeConverter()
  final DateTime? reminderAt;
  final String? certificateUrl;
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$VaccinationModelToJson(this);

  Vaccination toEntity() => Vaccination(
        id: id,
        ownerId: ownerId,
        petId: petId,
        vaccineName: vaccineName,
        category: VaccineCategory.values.asNameMap()[category] ?? VaccineCategory.other,
        dateAdministered: dateAdministered ?? createdAt ?? DateTime(1970),
        nextDueDate: nextDueDate,
        veterinarian: veterinarian,
        clinic: clinic,
        batchNumber: batchNumber,
        notes: notes,
        reminder: ReminderOffset.fromDays(reminderDaysBefore),
        certificateUrl: certificateUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
