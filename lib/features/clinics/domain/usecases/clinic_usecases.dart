import '../../../../core/errors/failure.dart';
import '../entities/clinic.dart';
import '../logic/geo.dart';
import '../repositories/clinic_repository.dart';

String? _trimOrNull(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Clinics sorted favourites first, then by name.
class WatchClinics {
  const WatchClinics(this._repository);

  final ClinicRepository _repository;

  Stream<List<Clinic>> call(String ownerId) => _repository.watchClinics(ownerId).map(
        (clinics) => [...clinics]..sort((a, b) {
            if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }),
      );
}

class WatchClinic {
  const WatchClinic(this._repository);

  final ClinicRepository _repository;

  Stream<Clinic?> call({required String ownerId, required String clinicId}) =>
      _repository.watchClinic(ownerId, clinicId);
}

/// Validates and stores a clinic. Returns its id.
class SaveClinic {
  const SaveClinic(this._repository);

  final ClinicRepository _repository;

  Future<String> call({required String ownerId, required Clinic clinic}) async {
    final name = clinic.name.trim();
    if (name.isEmpty) throw const Failure('Clinic name is required', code: 'invalid-name');
    final email = _trimOrNull(clinic.email);
    if (email != null && !_email.hasMatch(email)) {
      throw const Failure('Enter a valid email address', code: 'invalid-email');
    }

    final id = clinic.isNew ? _repository.newClinicId(ownerId) : clinic.id;
    await _repository.saveClinic(clinic.copyWith(
      id: id,
      ownerId: ownerId,
      name: name,
      address: _trimOrNull(clinic.address),
      phone: _trimOrNull(clinic.phone),
      email: email,
      website: normalizeWebsite(clinic.website),
      openingHours: _trimOrNull(clinic.openingHours),
      notes: _trimOrNull(clinic.notes),
    ));
    return id;
  }
}

class ToggleFavoriteClinic {
  const ToggleFavoriteClinic(this._repository);

  final ClinicRepository _repository;

  Future<void> call(Clinic clinic) =>
      _repository.saveClinic(clinic.copyWith(isFavorite: !clinic.isFavorite));
}

/// Deletes a clinic and detaches its veterinarians (they are kept).
class DeleteClinic {
  const DeleteClinic(this._repository);

  final ClinicRepository _repository;

  Future<void> call({required String ownerId, required String clinicId}) async {
    final vets = await _repository.watchVets(ownerId).first;
    for (final vet in vets.where((v) => v.clinicId == clinicId)) {
      await _repository.saveVet(vet.copyWith(clinicId: null));
    }
    await _repository.deleteClinic(ownerId, clinicId);
  }
}

/// Veterinarians sorted by name.
class WatchVets {
  const WatchVets(this._repository);

  final ClinicRepository _repository;

  Stream<List<Veterinarian>> call(String ownerId) => _repository.watchVets(ownerId).map(
        (vets) => [...vets]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      );
}

class SaveVet {
  const SaveVet(this._repository);

  final ClinicRepository _repository;

  Future<String> call({required String ownerId, required Veterinarian vet}) async {
    final name = vet.name.trim();
    if (name.isEmpty) throw const Failure('Veterinarian name is required', code: 'invalid-name');
    final email = _trimOrNull(vet.email);
    if (email != null && !_email.hasMatch(email)) {
      throw const Failure('Enter a valid email address', code: 'invalid-email');
    }
    final id = vet.isNew ? _repository.newVetId(ownerId) : vet.id;
    await _repository.saveVet(vet.copyWith(
      id: id,
      ownerId: ownerId,
      name: name,
      specialization: _trimOrNull(vet.specialization),
      phone: _trimOrNull(vet.phone),
      email: email,
      notes: _trimOrNull(vet.notes),
    ));
    return id;
  }
}

class DeleteVet {
  const DeleteVet(this._repository);

  final ClinicRepository _repository;

  Future<void> call({required String ownerId, required String vetId}) =>
      _repository.deleteVet(ownerId, vetId);
}
