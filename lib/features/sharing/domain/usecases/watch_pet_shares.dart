import '../entities/pet_share.dart';
import '../repositories/sharing_repository.dart';

class WatchPetShares {
  const WatchPetShares(this._repository);

  final SharingRepository _repository;

  Stream<List<PetShare>> call({required String ownerId, required String petId}) =>
      _repository.watchPetShares(ownerId: ownerId, petId: petId);
}
