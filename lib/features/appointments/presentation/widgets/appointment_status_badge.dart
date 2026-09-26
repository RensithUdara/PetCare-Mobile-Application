import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_overview.dart';

extension AppointmentDisplayStatusStyle on AppointmentDisplayStatus {
  StatusTone get tone => switch (this) {
        AppointmentDisplayStatus.upcoming => StatusTone.info,
        AppointmentDisplayStatus.today => StatusTone.warning,
        AppointmentDisplayStatus.past => StatusTone.danger,
        AppointmentDisplayStatus.completed => StatusTone.success,
        AppointmentDisplayStatus.cancelled => StatusTone.neutral,
      };

  Color color(BuildContext context) => tone.colorOf(context);
}

extension AppointmentTypeIcon on AppointmentType {
  IconData get icon => switch (this) {
        AppointmentType.routineCheckup => Icons.health_and_safety_outlined,
        AppointmentType.vaccination => Icons.vaccines_outlined,
        AppointmentType.dental => Icons.mood_outlined,
        AppointmentType.surgery => Icons.medical_services_outlined,
        AppointmentType.emergency => Icons.emergency_outlined,
        AppointmentType.followUp => Icons.replay_outlined,
        AppointmentType.grooming => Icons.content_cut,
        AppointmentType.other => Icons.event_note_outlined,
      };
}

class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({super.key, required this.status});

  final AppointmentDisplayStatus status;

  @override
  Widget build(BuildContext context) => StatusBadge(label: status.label, tone: status.tone);
}
