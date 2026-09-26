import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_widgets.dart';

/// Bell for [BrandAppBar]: opens the health-alerts sheet. Pass
/// [alertCount] where the dashboard is already loaded to show a badge.
class AlertsBellButton extends StatelessWidget {
  const AlertsBellButton({super.key, this.alertCount = 0});

  final int alertCount;

  @override
  Widget build(BuildContext context) => BrandActionButton(
        icon: alertCount > 0 ? Icons.notifications_active_outlined : Icons.notifications_none_rounded,
        tooltip: 'Health alerts',
        badgeCount: alertCount,
        onPressed: () => showAlertsSheet(context),
      );
}

Future<void> showAlertsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AlertsSheet(),
    );

class _AlertsSheet extends ConsumerWidget {
  const _AlertsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final now = ref.watch(clockProvider)();
    final theme = Theme.of(context);

    void open(String route) {
      Navigator.of(context).pop();
      context.push(route);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const IconBadge(icon: Icons.notifications_active_outlined, accent: FeatureAccent.emergency),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Health alerts',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  tooltip: 'Reminder settings',
                  icon: const Icon(Icons.tune),
                  onPressed: () => open(AppRoutes.notificationSettings),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: dashboard.when(
                loading: () => const SizedBox(height: 160, child: LoadingView()),
                error: (_, _) => ErrorView(
                  message: 'Could not load alerts.',
                  onRetry: () => ref.invalidate(dashboardProvider),
                ),
                data: (d) => d.alerts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(
                          icon: Icons.check_circle_outline,
                          title: 'All caught up',
                          message: 'No overdue or upcoming vaccinations and appointments need attention.',
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: d.alerts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final alert = d.alerts[i];
                          return AlertCard(alert: alert, now: now, onTap: () => open(alert.route));
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
