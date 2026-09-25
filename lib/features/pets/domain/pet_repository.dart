import 'dart:typed_data';

import 'pet.dart';

/// Persistence contract for pets and their profile photos.
///
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class PetRepository {
  /// All pets owned by [ownerId], ordered by name.
  Stream<List<Pet>> watchPets(String ownerId);

  /// A single pet, or `null` once it has been deleted.
  Stream<Pet?> watchPet(String ownerId, String petId);

  /// Reserves an id so a photo can be uploaded before the pet is saved.
  String newPetId(String ownerId);

  /// Creates or overwrites the pet with [Pet.id].
  Future<void> savePet(Pet pet);

  /// Deletes the pet and all of its stored photos.
  Future<void> deletePet(String ownerId, String petId);

  /// Uploads a (pre-compressed) JPEG and returns its download URL.
  /// Each upload gets a unique path so cached images never go stale.
  Future<String> uploadPhoto({
    required String ownerId,
    required String petId,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  });

  /// Deletes a previously uploaded photo by its download URL.
  Future<void> deletePhoto(String photoUrl);
}
