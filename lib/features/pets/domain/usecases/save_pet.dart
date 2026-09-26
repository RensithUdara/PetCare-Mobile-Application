import '../entities/pet.dart';
import '../entities/photo_change.dart';
import '../repositories/pet_repository.dart';

/// Creates or updates a pet and applies any photo change.
///
/// Ordering matters: a new photo is uploaded first, the pet is saved
/// pointing at it, and only then is the old file deleted — so a failure at
/// any step never leaves the pet referencing a missing photo.
class SavePet {
  const SavePet(this._repository);

  final PetRepository _repository;

  /// Returns the saved pet's id.
  Future<String> call({
    required String ownerId,
    required Pet pet,
    PhotoChange photo = const PhotoUnchanged(),
    void Function(double progress)? onUploadProgress,
  }) async {
    final id = pet.isNew ? _repository.newPetId(ownerId) : pet.id;
    final oldPhotoUrl = pet.photoUrl;

    final photoUrl = switch (photo) {
      PhotoReplaced(:final bytes) => await _repository.uploadPhoto(
          ownerId: ownerId,
          petId: id,
          bytes: bytes,
          onProgress: onUploadProgress,
        ),
      PhotoRemoved() => null,
      PhotoUnchanged() => oldPhotoUrl,
    };

    await _repository.savePet(pet.copyWith(id: id, ownerId: ownerId, photoUrl: photoUrl));

    if (oldPhotoUrl != null && oldPhotoUrl != photoUrl) {
      try {
        await _repository.deletePhoto(oldPhotoUrl);
      } catch (_) {
        // An orphaned file is harmless; don't fail the save.
      }
    }
    return id;
  }
}
