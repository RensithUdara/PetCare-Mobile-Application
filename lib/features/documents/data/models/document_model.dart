import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json_converters.dart';
import '../../domain/entities/medical_document.dart';

part 'document_model.g.dart';

/// Firestore representation of a [MedicalDocument]
/// (`users/{uid}/documents/{id}`).
@JsonSerializable(includeIfNull: true)
class DocumentModel {
  const DocumentModel({
    this.id = '',
    required this.ownerId,
    required this.petId,
    required this.name,
    this.type,
    required this.date,
    required this.fileUrl,
    required this.storagePath,
    required this.fileName,
    required this.contentType,
    this.sizeBytes = 0,
    this.description,
    this.vaccinationId,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => _$DocumentModelFromJson(json);

  factory DocumentModel.fromEntity(MedicalDocument d) => DocumentModel(
        id: d.id,
        ownerId: d.ownerId,
        petId: d.petId,
        name: d.name,
        type: d.type.name,
        date: d.date,
        fileUrl: d.fileUrl,
        storagePath: d.storagePath,
        fileName: d.fileName,
        contentType: d.contentType,
        sizeBytes: d.sizeBytes,
        description: d.description,
        vaccinationId: d.vaccinationId,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      );

  @JsonKey(includeToJson: false)
  final String id;
  final String ownerId;
  final String petId;
  final String name;
  final String? type;
  @NullableDateTimeConverter()
  final DateTime? date;
  final String fileUrl;
  final String storagePath;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String? description;
  final String? vaccinationId;
  @NullableDateTimeConverter()
  final DateTime? createdAt;
  @NullableDateTimeConverter()
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);

  MedicalDocument toEntity() => MedicalDocument(
        id: id,
        ownerId: ownerId,
        petId: petId,
        name: name,
        type: DocumentType.values.asNameMap()[type] ?? DocumentType.other,
        date: date ?? createdAt ?? DateTime(1970),
        fileUrl: fileUrl,
        storagePath: storagePath,
        fileName: fileName,
        contentType: contentType,
        sizeBytes: sizeBytes,
        description: description,
        vaccinationId: vaccinationId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
