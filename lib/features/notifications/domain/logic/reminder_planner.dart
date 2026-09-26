import '../../../../core/utils/date_utils.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/logic/medication_schedule.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../../vaccinations/domain/entities/vaccination.dart';
import '../../../vaccinations/domain/logic/vaccination_status.dart';
import '../entities/notification_settings.dart';
import '../entities/reminder.dart';

/// Medication doses are scheduled this many days ahead; the plan is
/// refreshed whenever the app runs or data changes.
const medicationHorizonDays = 3;

/// iOS keeps at most 64 pending local notifications per app; stay below.
const maxPendingReminders = 60;

/// Formats a time of day for notification text (e.g. "10:30 AM"). Injected
/// so the domain stays free of localisation packages.
typedef TimeFormatter = String Function(DateTime time);

/// Turns the user's records into the notifications that should currently
/// be scheduled on this device: future reminders only, soonest first,
/// capped at [maxPendingReminders]. Records of deleted pets are ignored.
List<PlannedReminder> planReminders({
  required List<Pet> pets,
  required List<Vaccination> vaccinations,
  required List<Appointment> appointments,
  required List<Medication> medications,
  required NotificationSettings settings,
  required DateTime now,
  required TimeFormatter formatTime,
}) {
  if (!settings.enabled) return const [];
  final names = {for (final p in pets) p.id: p.name};
  final plan = <PlannedReminder>[];

  void add(ReminderTarget target, DateTime fireAt, String title, String body) {
    if (!fireAt.isAfter(now)) return;
    plan.add(PlannedReminder(
      id: reminderId(target, fireAt),
      target: target,
      title: title,
      body: body,
      fireAt: fireAt,
    ));
  }

  if (settings.allows(ReminderCategory.vaccination)) {
    final byPet = <String, List<Vaccination>>{};
    for (final v in vaccinations) {
      if (names.containsKey(v.petId)) byPet.putIfAbsent(v.petId, () => []).add(v);
    }
    for (final MapEntry(key: petId, value: list) in byPet.entries) {
      // Only the latest dose of each vaccine is still relevant.
      for (final entry in buildVaccinationOverview(list, now).current) {
        final v = entry.vaccination;
        final fireAt = v.reminderDate;
        if (fireAt == null) continue;
        add(
          ReminderTarget(ReminderCategory.vaccination, v.id),
          fireAt,
          'Vaccination reminder',
          '${names[petId]}’s ${v.vaccineName} vaccination is due '
              '${_relativeDay(fireAt, v.nextDueDate!)}.',
        );
      }
    }
  }

  if (settings.allows(ReminderCategory.appointment)) {
    for (final a in appointments) {
      final petName = names[a.petId];
      final fireAt = a.reminderDate;
      if (petName == null || fireAt == null) continue;
      add(
        ReminderTarget(ReminderCategory.appointment, a.id),
        fireAt,
        'Appointment reminder',
        '$petName has a veterinary appointment '
            '${_relativeDay(fireAt, a.dateTime)} at ${formatTime(a.dateTime)}.',
      );
    }
  }

  if (settings.allows(ReminderCategory.medication)) {
    final today = dateOnly(now);
    for (final m in medications) {
      final petName = names[m.petId];
      if (petName == null || !m.remindersEnabled) continue;
      for (var i = 0; i <= medicationHorizonDays; i++) {
        final day = DateTime(today.year, today.month, today.day + i);
        for (final dose in dosesOn(m, day)) {
          add(
            ReminderTarget(ReminderCategory.medication, m.id),
            dose,
            'Medication reminder',
            'It’s time for $petName’s ${m.name} (${m.dosage}).',
          );
        }
      }
    }
  }

  plan.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return plan.length > maxPendingReminders ? plan.sublist(0, maxPendingReminders) : plan;
}

/// "today", "tomorrow" or "in 7 days", as seen from the moment [fireAt].
String _relativeDay(DateTime fireAt, DateTime event) => switch (daysBetween(fireAt, event)) {
      <= 0 => 'today',
      1 => 'tomorrow',
      final n => 'in $n days',
    };

/// Deterministic 31-bit id (FNV-1a) so re-planning yields the same ids.
int reminderId(ReminderTarget target, DateTime fireAt) {
  var hash = 0x811c9dc5;
  for (final unit in '${target.payload}@${fireAt.millisecondsSinceEpoch}'.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
