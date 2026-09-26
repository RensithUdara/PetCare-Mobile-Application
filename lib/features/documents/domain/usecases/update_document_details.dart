import '../../../../core/errors/failure.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/medical_document.dart';
import '../repositories/document_repository.dart';

/// Edits a document's metadata (the file itself is immutable).
class UpdateDocumentDetails {
  const UpdateDocumentDetails(this._repository);

  final DocumentRepository _repository;

  Future<void> call(
    MedicalDocument document, {
    required String name,
    required DocumentType type,
    required DateTime date,
    String? description,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const Failure('Document name is required', code: 'invalid-name');
    final d = description?.trim();
    await _repository.save(document.copyWith(
      name: trimmed,
      type: type,
      date: dateOnly(date),
      description: (d == null || d.isEmpty) ? null : d,
    ));
  }
}
