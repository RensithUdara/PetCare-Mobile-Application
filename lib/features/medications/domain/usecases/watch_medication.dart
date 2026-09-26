import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class WatchMedication {
  const WatchMedication(this._repository);

  final MedicationRepository _repository;

  Stream<Medication?> call({required String ownerId, required String medicationId}) =>
      _repository.watchOne(ownerId, medicationId);
}
