import '../entities/vaccination_overview.dart';
import '../logic/vaccination_status.dart';
import '../repositories/vaccination_repository.dart';

/// Streams a pet's vaccinations evaluated into statuses and history.
class WatchPetVaccinationOverview {
  const WatchPetVaccinationOverview(this._repository, this._now);

  final VaccinationRepository _repository;
  final DateTime Function() _now;

  Stream<VaccinationOverview> call({required String ownerId, required String petId}) =>
      _repository
          .watchForPet(ownerId, petId)
          .map((all) => buildVaccinationOverview(all, _now()));
}
