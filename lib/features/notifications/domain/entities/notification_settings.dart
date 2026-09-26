import 'package:meta/meta.dart';

import 'reminder.dart';

/// App-wide reminder preferences. Per-record reminder offsets live on the
/// records themselves; these switches gate whole categories.
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.vaccinations = true,
    this.appointments = true,
    this.medications = true,
  });

  final bool enabled;
  final bool vaccinations;
  final bool appointments;
  final bool medications;

  bool allows(ReminderCategory category) =>
      enabled &&
      switch (category) {
        ReminderCategory.vaccination => vaccinations,
        ReminderCategory.appointment => appointments,
        ReminderCategory.medication => medications,
      };

  NotificationSettings copyWith({
    bool? enabled,
    bool? vaccinations,
    bool? appointments,
    bool? medications,
  }) =>
      NotificationSettings(
        enabled: enabled ?? this.enabled,
        vaccinations: vaccinations ?? this.vaccinations,
        appointments: appointments ?? this.appointments,
        medications: medications ?? this.medications,
      );

  NotificationSettings withCategory(ReminderCategory category, bool value) => switch (category) {
        ReminderCategory.vaccination => copyWith(vaccinations: value),
        ReminderCategory.appointment => copyWith(appointments: value),
        ReminderCategory.medication => copyWith(medications: value),
      };

  @override
  bool operator ==(Object other) =>
      other is NotificationSettings &&
      other.enabled == enabled &&
      other.vaccinations == vaccinations &&
      other.appointments == appointments &&
      other.medications == medications;

  @override
  int get hashCode => Object.hash(enabled, vaccinations, appointments, medications);
}
