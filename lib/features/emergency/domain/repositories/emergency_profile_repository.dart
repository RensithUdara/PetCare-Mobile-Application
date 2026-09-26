import '../../../pets/domain/repositories/pet_records_cleaner.dart';
import '../entities/emergency_profile.dart';

/// Private settings (`users/{uid}/emergencyProfiles/{petId}`) and the public
/// snapshot (`publicProfiles/{publicId}`). Deleting a pet removes both.
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class EmergencyProfileRepository implements PetRecordsCleaner {
  Stream<EmergencyProfile?> watchSettings(String ownerId, String petId);

  Future<EmergencyProfile?> getSettings(String ownerId, String petId);

  Future<void> saveSettings(EmergencyProfile settings);

  Future<bool> publicIdExists(String publicId);

  Future<void> publish(PublicPetProfile profile);

  Future<void> unpublish(String publicId);

  /// Readable without signing in.
  Stream<PublicPetProfile?> watchPublic(String publicId);
}
