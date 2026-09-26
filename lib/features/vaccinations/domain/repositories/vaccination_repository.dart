import '../../../pets/domain/repositories/pet_records_cleaner.dart';
import '../entities/vaccination.dart';

/// Persistence contract for vaccination records.
///
/// Also a [PetRecordsCleaner], so deleting a pet removes its vaccinations.
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class VaccinationRepository implements PetRecordsCleaner {
  Stream<List<Vaccination>> watchForPet(String ownerId, String petId);

  /// Every vaccination of every pet (used by dashboard / calendar).
  Stream<List<Vaccination>> watchAll(String ownerId);

  Stream<Vaccination?> watchOne(String ownerId, String vaccinationId);

  String newId(String ownerId);

  Future<void> save(Vaccination vaccination);

  Future<void> delete(String ownerId, String vaccinationId);
}
