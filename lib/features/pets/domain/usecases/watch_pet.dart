import '../entities/pet.dart';
import '../repositories/pet_repository.dart';

class WatchPet {
  const WatchPet(this._repository);

  final PetRepository _repository;

  Stream<Pet?> call(String ownerId, String petId) => _repository.watchPet(ownerId, petId);
}
