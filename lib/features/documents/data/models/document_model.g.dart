// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      petId: json['petId'] as String,
      name: json['name'] as String,
      type: json['type'] as String?,
      date: const NullableDateTimeConverter().fromJson(json['date']),
      fileUrl: json['fileUrl'] as String,
      storagePath: json['storagePath'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      vaccinationId: json['vaccinationId'] as String?,
      createdAt: const NullableDateTimeConverter().fromJson(json['createdAt']),
      updatedAt: const NullableDateTimeConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'ownerId': instance.ownerId,
      'petId': instance.petId,
      'name': instance.name,
      'type': instance.type,
      'date': const NullableDateTimeConverter().toJson(instance.date),
      'fileUrl': instance.fileUrl,
      'storagePath': instance.storagePath,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'sizeBytes': instance.sizeBytes,
      'description': instance.description,
      'vaccinationId': instance.vaccinationId,
      'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
    };
