import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../domain/entities/vaccination_overview.dart';
import '../providers/vaccination_providers.dart';
import 'vaccination_status_badge.dart';

/// Summary row on the pet profile linking to the vaccinations screen,
/// e.g. "3 records · Next: Rabies, Oct 20, 2026".
class PetVaccinationsTile extends ConsumerWidget {
  const PetVaccinationsTile({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(petVaccinationOverviewProvider(petId)).value;

    String subtitle;
    Widget? trailing;
    if (overview == null) {
      subtitle = 'Loading…';
    } else if (overview.totalRecords == 0) {
      subtitle = 'No records yet';
    } else {
      final records = '${overview.totalRecords} record${overview.totalRecords == 1 ? '' : 's'}';
      final overdue = overview.count(VaccinationStatus.overdue);
      final next = overview.nextDue;
      if (overdue > 0) {
        subtitle = '$records · $overdue overdue';
        trailing = const VaccinationStatusBadge(status: VaccinationStatus.overdue);
      } else if (next != null) {
        subtitle = '$records · Next: ${next.vaccination.vaccineName}, '
            '${DateFormat.yMMMd().format(next.vaccination.nextDueDate!)}';
        if (next.status == VaccinationStatus.upcoming) {
          trailing = const VaccinationStatusBadge(status: VaccinationStatus.upcoming);
        }
      } else {
        subtitle = records;
      }
    }

    return ListTile(
      leading: const IconBadge(icon: Icons.vaccines_outlined, accent: FeatureAccent.vaccinations),
      title: const Text('Vaccinations'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          if (trailing != null) ...[const SizedBox(height: 6), trailing],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(AppRoutes.vaccinations(petId)),
    );
  }
}
