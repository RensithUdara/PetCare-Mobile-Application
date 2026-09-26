import '../../../../core/errors/failure.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/vaccination.dart';
import '../repositories/vaccination_repository.dart';

/// Validates and stores a vaccination record. Returns its id.
class SaveVaccination {
  const SaveVaccination(this._repository, this._now);

  final VaccinationRepository _repository;
  final DateTime Function() _now;

  Future<String> call({required String ownerId, required Vaccination vaccination}) async {
    final name = vaccination.vaccineName.trim();
    if (name.isEmpty) {
      throw const Failure('Vaccine name is required', code: 'invalid-name');
    }
    if (dateOnly(vaccination.dateAdministered).isAfter(dateOnly(_now()))) {
      throw const Failure('Date administered cannot be in the future',
          code: 'invalid-administered-date');
    }
    final due = vaccination.nextDueDate;
    if (due != null && !dateOnly(due).isAfter(dateOnly(vaccination.dateAdministered))) {
      throw const Failure('Next due date must be after the date administered',
          code: 'invalid-due-date');
    }

    final id = vaccination.isNew ? _repository.newId(ownerId) : vaccination.id;
    await _repository.save(vaccination.copyWith(
      id: id,
      ownerId: ownerId,
      vaccineName: name,
      // A reminder without a due date is meaningless.
      reminder: due == null ? null : vaccination.reminder,
    ));
    return id;
  }
}
