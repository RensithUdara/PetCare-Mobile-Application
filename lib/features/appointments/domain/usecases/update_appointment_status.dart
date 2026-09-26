import '../../../../core/errors/failure.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

/// Marks an appointment completed or cancelled (or reopens it).
class UpdateAppointmentStatus {
  const UpdateAppointmentStatus(this._repository, this._now);

  final AppointmentRepository _repository;
  final DateTime Function() _now;

  Future<void> call({
    required Appointment appointment,
    required AppointmentStatus status,
  }) async {
    if (appointment.status == status) return;
    if (status == AppointmentStatus.completed && appointment.dateTime.isAfter(_now())) {
      throw const Failure(
        'You can mark an appointment completed once it has started',
        code: 'not-started',
      );
    }
    await _repository.save(appointment.copyWith(status: status));
  }
}
