import '../../../pets/domain/repositories/pet_records_cleaner.dart';
import '../entities/doctor_profile.dart';
import '../entities/pet_share.dart';

/// Owner-side sharing of pet records with doctors. Implementations throw
/// [Failure]. As a [PetRecordsCleaner], deleting a pet revokes its shares.
abstract interface class SharingRepository implements PetRecordsCleaner {
  /// The approved doctor with [code], or `null`.
  Future<DoctorProfile?> findDoctorByCode(String code);

  Stream<List<PetShare>> watchPetShares({required String ownerId, required String petId});

  Future<void> share(PetShare share);

  Future<void> revoke(PetShare share);
}
