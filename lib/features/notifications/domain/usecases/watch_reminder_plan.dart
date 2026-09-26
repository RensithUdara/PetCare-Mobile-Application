import '../../../../core/utils/stream_utils.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../pets/domain/repositories/pet_repository.dart';
import '../../../vaccinations/domain/entities/vaccination.dart';
import '../../../vaccinations/domain/repositories/vaccination_repository.dart';
import '../entities/notification_settings.dart';
import '../entities/reminder.dart';
import '../logic/reminder_planner.dart';

/// Streams the reminders that should be scheduled, re-planned on every
/// data change.
class WatchReminderPlan {
  const WatchReminderPlan(
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

  Stream<List<PlannedReminder>> call({
    required String ownerId,
    required NotificationSettings settings,
    required TimeFormatter formatTime,
  }) {
    if (!settings.enabled) return Stream.value(const []);
    return combineLatest(
      [
        _pets.watchPets(ownerId),
        _appointments.watchAll(ownerId),
        _vaccinations.watchAll(ownerId),
        _medications.watchAll(ownerId),
      ],
      (values) => planReminders(
        pets: values[0]! as List<Pet>,
        appointments: values[1]! as List<Appointment>,
        vaccinations: values[2]! as List<Vaccination>,
        medications: values[3]! as List<Medication>,
        settings: settings,
        now: _now(),
        formatTime: formatTime,
      ),
    );
  }
}
