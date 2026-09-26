import '../repositories/pet_records_cleaner.dart';
import '../repositories/pet_repository.dart';

/// Deletes a pet and every record attached to it.
class DeletePet {
  const DeletePet(this._repository, [this._cleaners = const []]);

  final PetRepository _repository;
  final List<PetRecordsCleaner> _cleaners;

  Future<void> call({required String ownerId, required String petId}) async {
    // Records first: if this fails the pet still exists and can be retried.
    for (final cleaner in _cleaners) {
      await cleaner.deleteAllForPet(ownerId: ownerId, petId: petId);
    }
    await _repository.deletePet(ownerId, petId);
  }
}
