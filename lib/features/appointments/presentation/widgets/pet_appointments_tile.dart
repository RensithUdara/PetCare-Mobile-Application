import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/appointment_overview.dart';
import '../providers/appointment_providers.dart';
import 'appointment_status_badge.dart';

/// Summary row on the pet profile linking to the appointments screen.
class PetAppointmentsTile extends ConsumerWidget {
  const PetAppointmentsTile({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(petAppointmentOverviewProvider(petId)).value;

    String subtitle;
    Widget? trailing;
    if (overview == null) {
      subtitle = 'Loading…';
    } else if (overview.total == 0) {
      subtitle = 'No appointments yet';
    } else if (overview.next case final next?) {
      final a = next.appointment;
      subtitle = 'Next: ${a.type.label}, ${DateFormat.MMMd().add_jm().format(a.dateTime)}';
      if (next.status == AppointmentDisplayStatus.today) {
        trailing = const AppointmentStatusBadge(status: AppointmentDisplayStatus.today);
      }
    } else {
      final needsUpdate = overview.count(AppointmentDisplayStatus.past);
      subtitle = needsUpdate > 0
          ? '$needsUpdate need${needsUpdate == 1 ? 's' : ''} an update'
          : '${overview.total} past appointment${overview.total == 1 ? '' : 's'}';
      if (needsUpdate > 0) {
        trailing = const AppointmentStatusBadge(status: AppointmentDisplayStatus.past);
      }
    }

    return ListTile(
      leading: const Icon(Icons.event_outlined),
      title: const Text('Appointments'),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [?trailing, const Icon(Icons.chevron_right)],
      ),
      onTap: () => context.go(AppRoutes.appointments(petId)),
    );
  }
}
