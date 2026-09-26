import '../entities/clinic.dart';

/// Persistence for the user's clinics and veterinarians.
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class ClinicRepository {
  Stream<List<Clinic>> watchClinics(String ownerId);

  Stream<Clinic?> watchClinic(String ownerId, String clinicId);

  String newClinicId(String ownerId);

  Future<void> saveClinic(Clinic clinic);

  Future<void> deleteClinic(String ownerId, String clinicId);

  Stream<List<Veterinarian>> watchVets(String ownerId);

  String newVetId(String ownerId);

  Future<void> saveVet(Veterinarian vet);

  Future<void> deleteVet(String ownerId, String vetId);
}
