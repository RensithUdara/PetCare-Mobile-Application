import '../entities/medication_overview.dart';
import '../logic/medication_overview_builder.dart';
import '../repositories/medication_repository.dart';

class WatchPetMedicationOverview {
  const WatchPetMedicationOverview(this._repository, this._now);

  final MedicationRepository _repository;
  final DateTime Function() _now;

  Stream<MedicationOverview> call({required String ownerId, required String petId}) =>
      _repository
          .watchForPet(ownerId, petId)
          .map((all) => buildMedicationOverview(all, _now()));
}
