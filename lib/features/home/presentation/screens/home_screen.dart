import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/greeting.dart';
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

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pagePadding,
                AppConstants.pagePadding,
                AppConstants.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${greetingFor(now)}${name == null ? '' : ', $name'} 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMMEEEEd().format(now),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
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
        box(SectionHeader(title: 'Health alerts (${d.alerts.length})')),
        SliverPadding(
          padding: pad,
          sliver: list(
            d.alerts,
            (a) => AlertCard(alert: a, now: now, onTap: () => context.push(a.route)),
          ),
        ),
      ],

      // ── Pets ───────────────────────────────────────────────────────────
      box(SectionHeader(
        title: 'Your pets',
        actionLabel: 'See all',
        onAction: () => context.go(AppRoutes.pets),
      )),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 150,
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
        box(const SectionHeader(title: 'Today’s medications')),
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
      box(SectionHeader(
        title: 'Upcoming',
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
        box(const SectionHeader(title: 'Recent activity')),
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
