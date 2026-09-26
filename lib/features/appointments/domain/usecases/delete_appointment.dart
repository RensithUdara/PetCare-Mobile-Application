import '../repositories/appointment_repository.dart';

class DeleteAppointment {
  const DeleteAppointment(this._repository);

  final AppointmentRepository _repository;

  Future<void> call({required String ownerId, required String appointmentId}) =>
      _repository.delete(ownerId, appointmentId);
}
