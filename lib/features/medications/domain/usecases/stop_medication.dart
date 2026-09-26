import '../../../../core/errors/failure.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/medication.dart';
import '../logic/medication_schedule.dart';
import '../repositories/medication_repository.dart';

/// Ends an active course today (today's doses still count).
class StopMedication {
  const StopMedication(this._repository, this._now);

  final MedicationRepository _repository;
  final DateTime Function() _now;

  Future<void> call(Medication medication) async {
    final now = _now();
    if (medicationStatus(medication, now) != MedicationStatus.active) {
      throw const Failure('Only an active medication can be stopped', code: 'not-active');
    }
    await _repository.save(medication.copyWith(endDate: dateOnly(now)));
  }
}
