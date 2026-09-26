import '../repositories/vaccination_repository.dart';

class DeleteVaccination {
  const DeleteVaccination(this._repository);

  final VaccinationRepository _repository;

  Future<void> call({required String ownerId, required String vaccinationId}) =>
      _repository.delete(ownerId, vaccinationId);
}
