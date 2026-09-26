import '../../../pets/domain/repositories/pet_records_cleaner.dart';
import '../entities/medical_document.dart';

/// Persistence contract for medical documents (metadata + files).
///
/// Also a [PetRecordsCleaner], so deleting a pet removes its documents.
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class DocumentRepository implements PetRecordsCleaner {
  Stream<List<MedicalDocument>> watchForPet(String ownerId, String petId);

  Stream<List<MedicalDocument>> watchForVaccination(String ownerId, String vaccinationId);

  Stream<MedicalDocument?> watchOne(String ownerId, String documentId);

  String newId(String ownerId);

  Future<UploadedFile> uploadFile({
    required String ownerId,
    required String petId,
    required String documentId,
    required DocumentFile file,
    void Function(double progress)? onProgress,
  });

  /// Deletes a stored file; missing files are ignored.
  Future<void> deleteFile(String storagePath);

  Future<void> save(MedicalDocument document);

  /// Deletes the record and its file.
  Future<void> delete(MedicalDocument document);
}
