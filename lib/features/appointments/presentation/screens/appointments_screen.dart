import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/appointment_overview.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_card.dart';

/// A pet's appointments: upcoming and history.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petName = ref.watch(petProvider(petId)).value?.name;
    final overview = ref.watch(petAppointmentOverviewProvider(petId));
    void add() => context.push(AppRoutes.appointmentNew(petId: petId));
    void open(AppointmentEntry e) =>
        context.push(AppRoutes.appointmentDetails(petId, e.appointment.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: BrandAppBar.page(
          title: petName == null ? 'Appointments' : '$petName’s Appointments',
          bottom: (overview.value?.total ?? 0) > 0
              ? TabBar(tabs: [
                  Tab(text: 'Upcoming (${overview.value!.upcoming.length})'),
                  const Tab(text: 'History'),
                ])
              : null,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: add,
          icon: const Icon(Icons.add),
          label: const Text('New Appointment'),
        ),
        body: overview.when(
          loading: () => const LoadingView(),
          error: (_, _) => ErrorView(
            message: 'Could not load appointments.',
            onRetry: () => ref.invalidate(petAppointmentOverviewProvider(petId)),
          ),
          data: (overview) {
            if (overview.total == 0) {
              return const EmptyState(
                icon: Icons.event_outlined,
                title: 'No appointments yet',
                message: 'Schedule vet visits and get reminded before they happen.',
              );
            }
            return TabBarView(
              children: [
                _AppointmentList(
                  entries: overview.upcoming,
                  empty: 'No upcoming appointments',
                  onTap: open,
                ),
                _AppointmentList(
                  entries: overview.history,
                  empty: 'No past appointments',
                  onTap: open,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({required this.entries, required this.empty, required this.onTap});

  final List<AppointmentEntry> entries;
  final String empty;
  final ValueChanged<AppointmentEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return EmptyState(icon: Icons.event_available_outlined, title: empty);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => AppointmentCard(
        key: ValueKey(entries[i].appointment.id),
        entry: entries[i],
        onTap: () => onTap(entries[i]),
      ),
    );
  }
}
