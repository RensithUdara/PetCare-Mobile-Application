import '../entities/pet_share.dart';
import '../repositories/sharing_repository.dart';

class RevokeShare {
  const RevokeShare(this._repository);

  final SharingRepository _repository;

  Future<void> call(PetShare share) => _repository.revoke(share);
}
