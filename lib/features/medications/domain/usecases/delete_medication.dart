import '../repositories/medication_repository.dart';

class DeleteMedication {
  const DeleteMedication(this._repository);

  final MedicationRepository _repository;

  Future<void> call({required String ownerId, required String medicationId}) =>
      _repository.delete(ownerId, medicationId);
}
