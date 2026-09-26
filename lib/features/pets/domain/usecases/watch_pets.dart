import '../entities/pet.dart';
import '../repositories/pet_repository.dart';

class WatchPets {
  const WatchPets(this._repository);

  final PetRepository _repository;

  Stream<List<Pet>> call(String ownerId) => _repository.watchPets(ownerId);
}
