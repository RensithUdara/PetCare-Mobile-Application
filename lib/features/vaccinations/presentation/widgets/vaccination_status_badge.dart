import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/vaccination_overview.dart';

extension VaccinationStatusStyle on VaccinationStatus {
  StatusTone get tone => switch (this) {
        VaccinationStatus.upToDate => StatusTone.success,
        VaccinationStatus.upcoming => StatusTone.warning,
        VaccinationStatus.overdue => StatusTone.danger,
        VaccinationStatus.completed => StatusTone.info,
      };

  Color color(BuildContext context) => tone.colorOf(context);
}

class VaccinationStatusBadge extends StatelessWidget {
  const VaccinationStatusBadge({super.key, required this.status});

  final VaccinationStatus status;

  @override
  Widget build(BuildContext context) => StatusBadge(label: status.label, tone: status.tone);
}
