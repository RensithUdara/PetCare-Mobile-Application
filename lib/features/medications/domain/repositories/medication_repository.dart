import '../../../pets/domain/repositories/pet_records_cleaner.dart';
import '../entities/medication.dart';

/// Persistence contract for medications.
///
/// Also a [PetRecordsCleaner], so deleting a pet removes its medications.
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class MedicationRepository implements PetRecordsCleaner {
  Stream<List<Medication>> watchForPet(String ownerId, String petId);

  /// Every medication of every pet (calendar / dashboard).
  Stream<List<Medication>> watchAll(String ownerId);

  Stream<Medication?> watchOne(String ownerId, String medicationId);

  String newId(String ownerId);

  Future<void> save(Medication medication);

  Future<void> delete(String ownerId, String medicationId);
}
