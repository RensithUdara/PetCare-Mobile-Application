import '../entities/medical_document.dart';
import '../repositories/document_file_repository.dart';
import '../repositories/document_repository.dart';

int _newestFirst(MedicalDocument a, MedicalDocument b) {
  final byDate = b.date.compareTo(a.date);
  return byDate != 0 ? byDate : a.name.compareTo(b.name);
}

/// A pet's documents, newest first.
class WatchPetDocuments {
  const WatchPetDocuments(this._repository);

  final DocumentRepository _repository;

  Stream<List<MedicalDocument>> call({required String ownerId, required String petId}) =>
      _repository.watchForPet(ownerId, petId).map((docs) => [...docs]..sort(_newestFirst));
}

/// Certificates attached to a vaccination, newest first.
class WatchVaccinationDocuments {
  const WatchVaccinationDocuments(this._repository);

  final DocumentRepository _repository;

  Stream<List<MedicalDocument>> call({required String ownerId, required String vaccinationId}) =>
      _repository
          .watchForVaccination(ownerId, vaccinationId)
          .map((docs) => [...docs]..sort(_newestFirst));
}

class WatchDocument {
  const WatchDocument(this._repository);

  final DocumentRepository _repository;

  Stream<MedicalDocument?> call({required String ownerId, required String documentId}) =>
      _repository.watchOne(ownerId, documentId);
}

/// Deletes the record and file, and drops any cached copy on this device.
class DeleteDocument {
  const DeleteDocument(this._repository, [this._files]);

  final DocumentRepository _repository;
  final DocumentFileRepository? _files;

  Future<void> call(MedicalDocument document) async {
    await _repository.delete(document);
    try {
      await _files?.evict(document);
    } catch (_) {
      // A stale cache entry is harmless.
    }
  }
}
