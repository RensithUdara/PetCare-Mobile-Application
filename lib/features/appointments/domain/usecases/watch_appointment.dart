import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class WatchAppointment {
  const WatchAppointment(this._repository);

  final AppointmentRepository _repository;

  Stream<Appointment?> call({required String ownerId, required String appointmentId}) =>
      _repository.watchOne(ownerId, appointmentId);
}
