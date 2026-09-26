import '../../../pets/domain/repositories/pet_records_cleaner.dart';
import '../entities/appointment.dart';

/// Persistence contract for appointments.
///
/// Also a [PetRecordsCleaner], so deleting a pet removes its appointments.
/// Implementations throw `Failure` with a user-presentable message.
abstract interface class AppointmentRepository implements PetRecordsCleaner {
  Stream<List<Appointment>> watchForPet(String ownerId, String petId);

  /// Every appointment of every pet (calendar / dashboard).
  Stream<List<Appointment>> watchAll(String ownerId);

  Stream<Appointment?> watchOne(String ownerId, String appointmentId);

  String newId(String ownerId);

  Future<void> save(Appointment appointment);

  Future<void> delete(String ownerId, String appointmentId);
}
