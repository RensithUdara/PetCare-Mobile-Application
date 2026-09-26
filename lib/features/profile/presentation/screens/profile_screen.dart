import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../home/presentation/widgets/alerts_bell.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/controllers/reminder_sync_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final name = user?.displayName ?? 'PetCare user';
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: const BrandAppBar(title: 'Profile', actions: [AlertsBellButton()]),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          GradientHeader(
            floating: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        initials.isEmpty ? '🐾' : initials,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                          Text(user?.email ?? '',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle(
                  title: 'Appearance',
                  icon: Icons.palette_outlined,
                  accent: FeatureAccent.medications,
                ),
                SoftCard(
                  padding: const EdgeInsets.all(12),
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light')),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark')),
                      ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_suggest_outlined),
                          label: Text('System')),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) =>
                        ref.read(themeModeProvider.notifier).setMode(selection.first),
                  ),
                ),
                const SectionTitle(
                  title: 'Settings',
                  icon: Icons.tune,
                  accent: FeatureAccent.settings,
                ),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: const IconBadge(
                      icon: Icons.notifications_outlined,
                      accent: FeatureAccent.documents,
                    ),
                    title: const Text('Notifications'),
                    subtitle: const Text('Vaccination, appointment and medication reminders'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.notificationSettings),
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5), width: 1.5),
                  ),
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your pets.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      // While still signed in: unregister this device and clear reminders.
      await ref.read(reminderSyncControllerProvider.notifier).prepareSignOut();
      await ref.read(signOutProvider)();
    } on Failure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
