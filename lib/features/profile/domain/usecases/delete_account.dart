import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../pets/domain/repositories/pet_repository.dart';
import '../../../pets/domain/usecases/delete_pet.dart';
import '../repositories/profile_repository.dart';

/// Permanently deletes the account and all of its data.
///
/// Identity is confirmed first, so nothing is deleted if that fails; the
/// login itself goes last, so a failure part-way can simply be retried.
class DeleteAccount {
  const DeleteAccount({
    required AuthRepository auth,
    required PetRepository pets,
    required DeletePet deletePet,
    required ProfileRepository profiles,
  })  : _auth = auth,
        _pets = pets,
        _deletePet = deletePet,
        _profiles = profiles;

  final AuthRepository _auth;
  final PetRepository _pets;
  final DeletePet _deletePet;
  final ProfileRepository _profiles;

  Future<void> call({required String uid, String? password}) async {
    await _auth.reauthenticate(password: password);
    // Each pet with its records, QR profile, documents and photos.
    for (final pet in await _pets.watchPets(uid).first) {
      await _deletePet(ownerId: uid, petId: pet.id);
    }
    await _profiles.deleteUserData(uid);
    await _auth.deleteCurrentUser();
  }
}
