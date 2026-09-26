import '../../../../core/errors/failure.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/dose_time.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Validates and stores a medication. Returns its id.
class SaveMedication {
  const SaveMedication(this._repository);

  final MedicationRepository _repository;

  Future<String> call({required String ownerId, required Medication medication}) async {
    final name = medication.name.trim();
    final dosage = medication.dosage.trim();
    if (name.isEmpty) throw const Failure('Medicine name is required', code: 'invalid-name');
    if (dosage.isEmpty) throw const Failure('Dosage is required', code: 'invalid-dosage');

    final start = dateOnly(medication.startDate);
    final end = medication.endDate == null ? null : dateOnly(medication.endDate!);
    if (end != null && end.isBefore(start)) {
      throw const Failure('End date cannot be before the start date', code: 'invalid-end-date');
    }

    // As-needed medication has no schedule, so nothing to remind about.
    final times = medication.frequency.isScheduled
        ? (medication.doseTimes.toSet().toList()..sort())
        : const <DoseTime>[];
    final remind = medication.remindersEnabled && times.isNotEmpty;
    if (medication.remindersEnabled && medication.frequency.isScheduled && times.isEmpty) {
      throw const Failure('Add at least one reminder time', code: 'missing-times');
    }

    final id = medication.isNew ? _repository.newId(ownerId) : medication.id;
    await _repository.save(medication.copyWith(
      id: id,
      ownerId: ownerId,
      name: name,
      dosage: dosage,
      startDate: start,
      endDate: end,
      doseTimes: times,
      remindersEnabled: remind,
      instructions: _trimOrNull(medication.instructions),
      veterinarian: _trimOrNull(medication.veterinarian),
      notes: _trimOrNull(medication.notes),
    ));
    return id;
  }

  static String? _trimOrNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
