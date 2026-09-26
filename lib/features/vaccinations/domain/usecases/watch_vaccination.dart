import '../entities/vaccination.dart';
import '../repositories/vaccination_repository.dart';

class WatchVaccination {
  const WatchVaccination(this._repository);

  final VaccinationRepository _repository;

  Stream<Vaccination?> call({required String ownerId, required String vaccinationId}) =>
      _repository.watchOne(ownerId, vaccinationId);
}
