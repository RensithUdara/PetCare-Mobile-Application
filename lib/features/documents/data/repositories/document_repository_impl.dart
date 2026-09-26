import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/medical_document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_data_source.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._remote);

  final DocumentRemoteDataSource _remote;

  static List<MedicalDocument> _toEntities(List<DocumentModel> models) =>
      models.map((m) => m.toEntity()).toList();

  /// Keeps storage paths safe: letters, digits, dot, dash, underscore.
  static String safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'file' : cleaned;
  }

  @override
  Stream<List<MedicalDocument>> watchForPet(String ownerId, String petId) => guardFirebaseStream(
        _remote.watchWhere(ownerId, 'petId', petId).map(_toEntities),
        message: 'Could not load documents.',
      );

  @override
  Stream<List<MedicalDocument>> watchForVaccination(String ownerId, String vaccinationId) =>
      guardFirebaseStream(
        _remote.watchWhere(ownerId, 'vaccinationId', vaccinationId).map(_toEntities),
        message: 'Could not load certificates.',
      );

  @override
  Stream<MedicalDocument?> watchOne(String ownerId, String documentId) => guardFirebaseStream(
        _remote.watchOne(ownerId, documentId).map((m) => m?.toEntity()),
        message: 'Could not load this document.',
      );

  @override
  String newId(String ownerId) => _remote.newId(ownerId);

  @override
  Future<UploadedFile> uploadFile({
    required String ownerId,
    required String petId,
    required String documentId,
    required DocumentFile file,
    void Function(double progress)? onProgress,
  }) =>
      guardFirebase(() async {
        final (url, path) = await _remote.upload(
          path: 'users/$ownerId/pets/$petId/documents/$documentId/${safeFileName(file.fileName)}',
          bytes: file.bytes,
          contentType: file.contentType,
          onProgress: onProgress,
        );
        return UploadedFile(url: url, storagePath: path);
      }, message: 'Could not upload the file. Please try again.');

  @override
  Future<void> deleteFile(String storagePath) =>
      guardFirebase(() => _remote.deleteFile(storagePath));

  @override
  Future<void> save(MedicalDocument document) {
    assert(!document.isNew, 'Document id must be set before saving');
    return guardFirebaseWrite(
      () => _remote.save(DocumentModel.fromEntity(document)),
      label: 'Save document',
      message: 'Could not save document. Please try again.',
    );
  }

  @override
  Future<void> delete(MedicalDocument document) => guardFirebaseWrite(() async {
        // Record first: a leftover file is invisible, a leftover record is broken.
        await _remote.deleteRecord(document.ownerId, document.id);
        try {
          await _remote.deleteFile(document.storagePath);
        } catch (_) {}
      }, label: 'Delete document', message: 'Could not delete document. Please try again.');

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) =>
      guardFirebaseWrite(() async {
        for (final doc in await _remote.listForPet(ownerId, petId)) {
          await _remote.deleteRecord(ownerId, doc.id);
          try {
            await _remote.deleteFile(doc.storagePath);
          } catch (_) {}
        }
      }, label: 'Delete documents', message: 'Could not delete this pet’s documents. Please try again.');
}
