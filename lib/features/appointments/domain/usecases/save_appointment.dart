import '../../../../core/errors/failure.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

/// Validates and stores an appointment. Returns its id.
class SaveAppointment {
  const SaveAppointment(this._repository, this._now);

  final AppointmentRepository _repository;
  final DateTime Function() _now;

  Future<String> call({required String ownerId, required Appointment appointment}) async {
    if (appointment.petId.isEmpty) {
      throw const Failure('Choose a pet for this appointment', code: 'invalid-pet');
    }

    var toSave = appointment;
    // Logging a visit that already happened: record it as completed rather
    // than leaving a "needs update" item behind.
    if (appointment.isNew &&
        appointment.isScheduled &&
        appointment.dateTime.isBefore(_now())) {
      toSave = toSave.copyWith(status: AppointmentStatus.completed);
    }

    final id = toSave.isNew ? _repository.newId(ownerId) : toSave.id;
    await _repository.save(toSave.copyWith(
      id: id,
      ownerId: ownerId,
      clinic: _trimOrNull(toSave.clinic),
      veterinarian: _trimOrNull(toSave.veterinarian),
      reason: _trimOrNull(toSave.reason),
      notes: _trimOrNull(toSave.notes),
    ));
    return id;
  }

  static String? _trimOrNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
