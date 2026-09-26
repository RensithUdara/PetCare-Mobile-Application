import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/medication_overview.dart';
import '../providers/medication_providers.dart';
import '../widgets/medication_widgets.dart';

/// A pet's medications grouped into Active / Starting soon / Completed.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petName = ref.watch(petProvider(petId)).value?.name;
    final overview = ref.watch(petMedicationOverviewProvider(petId));
    final now = ref.watch(clockProvider)();
    void add() => context.push(AppRoutes.medicationNew(petId));

    return Scaffold(
      appBar: AppBar(title: Text(petName == null ? 'Medications' : '$petName’s Medications')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: add,
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
      ),
      body: overview.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: 'Could not load medications.',
          onRetry: () => ref.invalidate(petMedicationOverviewProvider(petId)),
        ),
        data: (overview) {
          if (overview.total == 0) {
            return const EmptyState(
              icon: Icons.medication_outlined,
              title: 'No medications',
              message: 'Track dosage and schedules, and get reminded when a dose is due.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              for (final (title, entries) in [
                ('Active', overview.active),
                ('Starting soon', overview.upcoming),
                ('Completed', overview.completed),
              ])
                if (entries.isNotEmpty) ...[
                  _SectionHeader(title: title, count: entries.length),
                  for (final MedicationEntry entry in entries) ...[
                    MedicationCard(
                      key: ValueKey(entry.medication.id),
                      entry: entry,
                      now: now,
                      onTap: () => context.push(
                        AppRoutes.medicationDetails(petId, entry.medication.id),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Text('$title ($count)', style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
