/// Implemented by repositories that store per-pet records (vaccinations,
/// appointments, …) so deleting a pet can remove them without the pets
/// domain depending on those features.
abstract interface class PetRecordsCleaner {
  Future<void> deleteAllForPet({required String ownerId, required String petId});
}
