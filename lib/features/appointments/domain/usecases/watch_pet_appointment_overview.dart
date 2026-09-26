import '../entities/appointment_overview.dart';
import '../logic/appointment_status.dart';
import '../repositories/appointment_repository.dart';

class WatchPetAppointmentOverview {
  const WatchPetAppointmentOverview(this._repository, this._now);

  final AppointmentRepository _repository;
  final DateTime Function() _now;

  Stream<AppointmentOverview> call({required String ownerId, required String petId}) =>
      _repository
          .watchForPet(ownerId, petId)
          .map((all) => buildAppointmentOverview(all, _now()));
}
