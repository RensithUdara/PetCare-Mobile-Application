import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/vaccination_overview.dart';
import '../providers/vaccination_providers.dart';
import '../widgets/vaccination_card.dart';
import '../widgets/vaccination_status_badge.dart';
import '../widgets/vaccination_timeline.dart';

/// A pet's vaccinations: current status per vaccine, and full history.
class VaccinationsScreen extends ConsumerWidget {
  const VaccinationsScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petName = ref.watch(petProvider(petId)).value?.name;
    final overview = ref.watch(petVaccinationOverviewProvider(petId));
    final hasRecords = (overview.value?.totalRecords ?? 0) > 0;
    void add() => context.push(AppRoutes.vaccinationNew(petId));
    void open(VaccinationEntry e) =>
        context.push(AppRoutes.vaccinationDetails(petId, e.vaccination.id));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(petName == null ? 'Vaccinations' : '$petName’s Vaccinations'),
          bottom: hasRecords
              ? const TabBar(tabs: [Tab(text: 'Current'), Tab(text: 'History')])
              : null,
        ),
        floatingActionButton: hasRecords
            ? FloatingActionButton.extended(
                onPressed: add,
                icon: const Icon(Icons.add),
                label: const Text('Add Vaccination'),
              )
            : null,
        body: overview.when(
          loading: () => const LoadingView(),
          error: (_, _) => ErrorView(
            message: 'Could not load vaccinations.',
            onRetry: () => ref.invalidate(petVaccinationOverviewProvider(petId)),
          ),
          data: (overview) {
            if (overview.totalRecords == 0) {
              return EmptyState(
                icon: Icons.vaccines_outlined,
                title: 'No vaccinations yet',
                message: 'Record vaccinations to track due dates and get reminders.',
                action: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: add,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Vaccination'),
                ),
              );
            }
            final now = ref.watch(clockProvider)();
            const padding = EdgeInsets.fromLTRB(20, 16, 20, 96);
            return TabBarView(
              children: [
                ListView(
                  padding: padding,
                  children: [
                    _SummaryRow(overview: overview),
                    const SizedBox(height: 16),
                    for (final entry in overview.current) ...[
                      VaccinationCard(
                        key: ValueKey(entry.vaccination.id),
                        entry: entry,
                        now: now,
                        onTap: () => open(entry),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
                VaccinationTimeline(
                  historyByYear: overview.historyByYear,
                  onTap: open,
                  padding: padding,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.overview});

  final VaccinationOverview overview;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final status in const [
          VaccinationStatus.overdue,
          VaccinationStatus.upcoming,
          VaccinationStatus.upToDate,
        ]) ...[
          Expanded(child: _SummaryTile(status: status, count: overview.count(status))),
          if (status != VaccinationStatus.upToDate) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.status, required this.count});

  final VaccinationStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status.color(context);
    return Semantics(
      label: '$count ${status.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
            Text(status.label, style: theme.textTheme.labelMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
