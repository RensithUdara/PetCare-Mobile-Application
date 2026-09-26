import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._remote);

  final AppointmentRemoteDataSource _remote;

  static List<Appointment> _toEntities(List<AppointmentModel> models) =>
      models.map((m) => m.toEntity()).toList();

  @override
  Stream<List<Appointment>> watchForPet(String ownerId, String petId) => guardFirebaseStream(
        _remote.watchForPet(ownerId, petId).map(_toEntities),
        message: 'Could not load appointments.',
      );

  @override
  Stream<List<Appointment>> watchAll(String ownerId) => guardFirebaseStream(
        _remote.watchAll(ownerId).map(_toEntities),
        message: 'Could not load appointments.',
      );

  @override
  Stream<Appointment?> watchOne(String ownerId, String appointmentId) => guardFirebaseStream(
        _remote.watchOne(ownerId, appointmentId).map((m) => m?.toEntity()),
        message: 'Could not load this appointment.',
      );

  @override
  String newId(String ownerId) => _remote.newId(ownerId);

  @override
  Future<void> save(Appointment appointment) {
    assert(!appointment.isNew, 'Appointment id must be set before saving');
    return guardFirebaseWrite(
      () => _remote.save(AppointmentModel.fromEntity(appointment)),
      label: 'Save appointment',
      message: 'Could not save appointment. Please try again.',
    );
  }

  @override
  Future<void> delete(String ownerId, String appointmentId) => guardFirebaseWrite(
        () => _remote.delete(ownerId, appointmentId),
        label: 'Delete appointment',
        message: 'Could not delete appointment. Please try again.',
      );

  @override
  Future<void> deleteAllForPet({required String ownerId, required String petId}) =>
      guardFirebaseWrite(
        () => _remote.deleteAllForPet(ownerId, petId),
        label: 'Delete appointments',
        message: 'Could not delete this pet’s appointments. Please try again.',
      );
}
