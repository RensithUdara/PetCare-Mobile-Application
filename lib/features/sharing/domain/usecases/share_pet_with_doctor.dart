import '../../../../core/errors/failure.dart';
import '../entities/pet_share.dart';
import '../repositories/sharing_repository.dart';

class SharePetWithDoctor {
  const SharePetWithDoctor(this._repository);

  final SharingRepository _repository;

  Future<void> call(PetShare share) async {
    final existing = await _repository.watchPetShares(ownerId: share.ownerId, petId: share.petId).first;
    if (existing.any((s) => s.doctorId == share.doctorId)) {
      throw Failure('${share.doctorName} already has access to ${share.petName}.', code: 'already-shared');
    }
    await _repository.share(share);
  }
}
