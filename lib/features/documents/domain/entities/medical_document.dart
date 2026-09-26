import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_document.freezed.dart';

enum DocumentType {
  vaccinationCertificate('Vaccination certificate'),
  bloodTest('Blood test'),
  prescription('Prescription'),
  xRay('X-ray'),
  medicalReport('Medical report'),
  invoice('Invoice'),
  other('Other');

  const DocumentType(this.label);
  final String label;
}

/// A stored medical file (image or PDF) belonging to one pet.
@freezed
abstract class MedicalDocument with _$MedicalDocument {
  const MedicalDocument._();

  const factory MedicalDocument({
    /// Empty for a document that has not been saved yet.
    @Default('') String id,
    required String ownerId,
    required String petId,
    required String name,
    @Default(DocumentType.other) DocumentType type,

    /// Date on the document (e.g. when the test was done), date only.
    required DateTime date,
    required String fileUrl,

    /// Storage path, used to delete the file.
    required String storagePath,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    String? description,

    /// Set when this is the certificate for a vaccination record.
    String? vaccinationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MedicalDocument;

  bool get isNew => id.isEmpty;

  bool get isPdf => contentType == 'application/pdf';

  bool get isImage => contentType.startsWith('image/');
}

/// A file chosen by the user, ready to upload.
class DocumentFile {
  const DocumentFile({required this.bytes, required this.fileName, required this.contentType});

  final Uint8List bytes;
  final String fileName;
  final String contentType;

  int get sizeBytes => bytes.lengthInBytes;
}

/// Where an uploaded file ended up.
class UploadedFile {
  const UploadedFile({required this.url, required this.storagePath});

  final String url;
  final String storagePath;
}
