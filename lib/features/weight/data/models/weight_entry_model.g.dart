// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightEntryModel _$WeightEntryModelFromJson(Map<String, dynamic> json) =>
    WeightEntryModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      petId: json['petId'] as String,
      date: const NullableDateTimeConverter().fromJson(json['date']),
      weightKg: (json['weightKg'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$WeightEntryModelToJson(WeightEntryModel instance) =>
    <String, dynamic>{
      'ownerId': instance.ownerId,
      'petId': instance.petId,
      'date': const NullableDateTimeConverter().toJson(instance.date),
      'weightKg': instance.weightKg,
      'note': instance.note,
      'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
    };
