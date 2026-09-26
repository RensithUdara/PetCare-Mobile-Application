import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/greeting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../calendar/presentation/widgets/calendar_event_tile.dart';
import '../../domain/entities/dashboard.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final name = user?.displayName?.split(' ').first;
    final now = ref.watch(clockProvider)();
    final dashboard = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    final d = dashboard.value;

    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  MediaQuery.paddingOf(context).top + 20,
                  AppConstants.pagePadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMMEEEEd().format(now),
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${greetingFor(now)}${name == null ? '' : ', $name'} 👋',
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.pets, color: Colors.white),
                        ),
                      ],
                    ),
                    if (d != null && d.hasPets) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          HeaderStat(value: '${d.pets.length}', label: 'Pets', icon: Icons.pets),
                          const SizedBox(width: 10),
                          HeaderStat(
                            value: '${d.alerts.length}',
                            label: 'Alerts',
                            icon: Icons.notifications_active_outlined,
                          ),
                          const SizedBox(width: 10),
                          HeaderStat(
                            value: '${d.todaysDoses.length}',
                            label: 'Meds today',
                            icon: Icons.medication_outlined,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ...dashboard.when(
              loading: () => [const SliverFillRemaining(child: LoadingView())],
              error: (_, _) => [
                SliverFillRemaining(
                  child: ErrorView(
                    message: 'Could not load your dashboard.',
                    onRetry: () => ref.invalidate(dashboardProvider),
                  ),
                ),
              ],
              data: (d) => d.hasPets
                  ? _sections(context, d, now)
                  : [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.pets,
                          title: 'Welcome to ${AppConstants.appName}',
                          message: 'Add your first pet to track vaccinations, '
                              'appointments and medications.',
                          action: FilledButton.icon(
                            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                            onPressed: () => context.push(AppRoutes.petNew),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Pet'),
                          ),
                        ),
                      ),
                    ],
            ),
          ],
      ),
    );
  }

  List<Widget> _sections(BuildContext context, Dashboard d, DateTime now) {
    final muted = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    const pad = EdgeInsets.symmetric(horizontal: AppConstants.pagePadding);

    Widget box(Widget child) => SliverPadding(padding: pad, sliver: SliverToBoxAdapter(child: child));

    SliverList list<T>(List<T> items, Widget Function(T) builder) => SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => builder(items[i]),
        );

    return [
      // ── Alerts ─────────────────────────────────────────────────────────
      if (d.alerts.isNotEmpty) ...[
        box(SectionTitle(
          title: 'Health alerts (${d.alerts.length})',
          icon: Icons.warning_amber_rounded,
          accent: FeatureAccent.emergency,
        )),
        SliverPadding(
          padding: pad,
          sliver: list(
            d.alerts,
            (a) => AlertCard(alert: a, now: now, onTap: () => context.push(a.route)),
          ),
        ),
      ],

      // ── Quick actions ──────────────────────────────────────────────────
      box(Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            _QuickAction(
              icon: Icons.event_available,
              label: 'Appointment',
              accent: FeatureAccent.appointments,
              onTap: () => context.push(AppRoutes.appointmentNew()),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.calendar_month,
              label: 'Calendar',
              accent: FeatureAccent.calendar,
              onTap: () => context.go(AppRoutes.calendar),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.local_hospital,
              label: 'Find vets',
              accent: FeatureAccent.clinics,
              onTap: () => context.go(AppRoutes.clinicsMap),
            ),
          ],
        ),
      )),

      // ── Pets ───────────────────────────────────────────────────────────
      box(SectionTitle(
        title: 'Your pets',
        icon: Icons.pets,
        accent: FeatureAccent.pets,
        actionLabel: 'See all',
        onAction: () => context.go(AppRoutes.pets),
      )),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 172,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: pad,
            children: [
              for (final s in d.pets)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PetSummaryCard(
                    summary: s,
                    onTap: () => context.go(AppRoutes.petDetails(s.pet.id)),
                  ),
                ),
              AddPetCard(onTap: () => context.push(AppRoutes.petNew)),
            ],
          ),
        ),
      ),

      // ── Today's medications ────────────────────────────────────────────
      if (d.todaysDoses.isNotEmpty) ...[
        box(const SectionTitle(
          title: 'Today’s medications',
          icon: Icons.medication_outlined,
          accent: FeatureAccent.medications,
        )),
        SliverPadding(
          padding: pad,
          sliver: list(
            d.todaysDoses,
            (e) => CalendarEventTile(
              event: e,
              onTap: () => context.push(eventDetailsRoute(e, fromHome: true)),
            ),
          ),
        ),
      ],

      // ── Upcoming ───────────────────────────────────────────────────────
      box(SectionTitle(
        title: 'Upcoming',
        icon: Icons.event_outlined,
        accent: FeatureAccent.calendar,
        actionLabel: 'Calendar',
        onAction: () => context.go(AppRoutes.calendar),
      )),
      if (d.upcoming.isEmpty)
        box(Text('Nothing in the next 30 days.', style: muted))
      else
        SliverPadding(
          padding: pad,
          sliver: list(
            d.upcoming,
            (e) => CalendarEventTile(
              event: e,
              showDate: true,
              onTap: () => context.push(eventDetailsRoute(e, fromHome: true)),
            ),
          ),
        ),

      // ── Recent activity ────────────────────────────────────────────────
      if (d.recentActivity.isNotEmpty) ...[
        box(const SectionTitle(
          title: 'Recent activity',
          icon: Icons.history,
          accent: FeatureAccent.appointments,
        )),
        SliverPadding(
          padding: pad,
          sliver: SliverList.list(children: [
            for (final item in d.recentActivity)
              ActivityTile(item: item, onTap: () => context.push(item.route)),
          ]),
        ),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ];
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final FeatureAccent accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            IconBadge(icon: icon, accent: accent, size: 42),
            const SizedBox(height: 8),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
