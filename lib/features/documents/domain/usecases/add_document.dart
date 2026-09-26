import '../../../../core/errors/failure.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/medical_document.dart';
import '../repositories/document_repository.dart';

/// Uploads a file and creates its document record. Returns the new id.
class AddDocument {
  const AddDocument(this._repository);

  final DocumentRepository _repository;

  /// Must match `storage.rules`.
  static const maxSizeBytes = 10 * 1024 * 1024;
  static const allowedTypes = {'image/jpeg', 'image/png', 'image/heic', 'application/pdf'};

  Future<String> call({
    required String ownerId,
    required String petId,
    required String name,
    required DocumentType type,
    required DateTime date,
    required DocumentFile file,
    String? description,
    String? vaccinationId,
    void Function(double progress)? onProgress,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const Failure('Document name is required', code: 'invalid-name');
    if (!allowedTypes.contains(file.contentType)) {
      throw const Failure('Only images and PDF files can be uploaded', code: 'invalid-type');
    }
    if (file.sizeBytes > maxSizeBytes) {
      throw const Failure('Files must be smaller than 10 MB', code: 'too-large');
    }

    final id = _repository.newId(ownerId);
    final uploaded = await _repository.uploadFile(
      ownerId: ownerId,
      petId: petId,
      documentId: id,
      file: file,
      onProgress: onProgress,
    );

    try {
      await _repository.save(MedicalDocument(
        id: id,
        ownerId: ownerId,
        petId: petId,
        name: trimmed,
        type: type,
        date: dateOnly(date),
        fileUrl: uploaded.url,
        storagePath: uploaded.storagePath,
        fileName: file.fileName,
        contentType: file.contentType,
        sizeBytes: file.sizeBytes,
        description: _trimOrNull(description),
        vaccinationId: vaccinationId,
      ));
    } catch (_) {
      // Don't leave an orphaned file behind if the record can't be written.
      try {
        await _repository.deleteFile(uploaded.storagePath);
      } catch (_) {}
      rethrow;
    }
    return id;
  }
}

String? _trimOrNull(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}
