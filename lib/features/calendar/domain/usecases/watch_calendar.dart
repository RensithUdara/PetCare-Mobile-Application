import '../../../../core/utils/stream_utils.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/domain/repositories/pet_repository.dart';
import '../../../vaccinations/domain/entities/vaccination.dart';
import '../../../vaccinations/domain/repositories/vaccination_repository.dart';
import '../entities/calendar_snapshot.dart';
import '../logic/calendar_events.dart';

/// Live calendar of every pet's appointments, vaccination due dates and
/// medication schedules.
class WatchCalendar {
  const WatchCalendar(
    this._pets,
    this._appointments,
    this._vaccinations,
    this._medications,
    this._now,
  );

  final PetRepository _pets;
  final AppointmentRepository _appointments;
  final VaccinationRepository _vaccinations;
  final MedicationRepository _medications;
  final DateTime Function() _now;

  Stream<CalendarSnapshot> call(String ownerId) => combineLatest(
        [
          _pets.watchPets(ownerId),
          _appointments.watchAll(ownerId),
          _vaccinations.watchAll(ownerId),
          _medications.watchAll(ownerId),
        ],
        (values) => buildCalendarSnapshot(
          pets: values[0]! as List<Pet>,
          appointments: values[1]! as List<Appointment>,
          vaccinations: values[2]! as List<Vaccination>,
          medications: values[3]! as List<Medication>,
          now: _now(),
        ),
      );
}
