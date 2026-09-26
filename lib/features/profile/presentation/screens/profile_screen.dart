import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../clinics/presentation/providers/clinic_providers.dart';
import '../../../home/presentation/providers/dashboard_providers.dart';
import '../../../home/presentation/widgets/alerts_bell.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/account_controller.dart';
import '../providers/profile_providers.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final usesPassword = ref.watch(usesPasswordProvider);
    final busy = ref.watch(accountControllerProvider.select((s) => s.isBusy));

    ref.listen(accountControllerProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    });

    return Scaffold(
      appBar: const BrandAppBar(title: 'Profile', actions: [AlertsBellButton()]),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _ProfileHero(profile: profile),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsGroup(title: 'Account', children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    accent: FeatureAccent.pets,
                    title: 'Edit profile',
                    subtitle: 'Name, phone, city and photo',
                    onTap: () => context.push(AppRoutes.profileEdit),
                  ),
                  if (usesPassword)
                    SettingsTile(
                      icon: Icons.lock_outline,
                      accent: FeatureAccent.medications,
                      title: 'Change password',
                      subtitle: 'Keep your account secure',
                      onTap: () => context.push(AppRoutes.changePassword),
                    ),
                  SettingsTile(
                    icon: Icons.notifications_active_outlined,
                    accent: FeatureAccent.documents,
                    title: 'Notifications',
                    subtitle: 'Vaccination, appointment and medication reminders',
                    onTap: () => context.push(AppRoutes.notificationSettings),
                  ),
                ]),
                SettingsGroup(title: 'Preferences', children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            IconBadge(icon: Icons.palette_outlined, accent: FeatureAccent.calendar, size: 40),
                            SizedBox(width: 16),
                            Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
                            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
                            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.smartphone), label: Text('Auto')),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setMode(s.first),
                        ),
                      ],
                    ),
                  ),
                ]),
                SettingsGroup(title: 'Help & support', children: [
                  SettingsTile(
                    icon: Icons.help_outline,
                    accent: FeatureAccent.appointments,
                    title: 'Help & FAQ',
                    subtitle: 'Answers to common questions',
                    onTap: () => context.push(AppRoutes.faq),
                  ),
                  SettingsTile(
                    icon: Icons.support_agent,
                    accent: FeatureAccent.clinics,
                    title: 'Contact support',
                    subtitle: AppConstants.supportEmail,
                    onTap: () => showContactSupportSheet(context),
                  ),
                  SettingsTile(
                    icon: Icons.share_outlined,
                    accent: FeatureAccent.weight,
                    title: 'Share ${AppConstants.appName}',
                    subtitle: 'Tell other pet parents about the app',
                    onTap: () => SharePlus.instance.share(ShareParams(
                      text: 'I keep my pets’ vaccinations, vet visits and medications on track with '
                          '${AppConstants.appName}. Give it a try!',
                    )),
                  ),
                  SettingsTile(
                    icon: Icons.info_outline,
                    accent: FeatureAccent.settings,
                    title: 'About ${AppConstants.appName}',
                    subtitle: 'Version ${AppConstants.version}',
                    onTap: () => _showAbout(context),
                  ),
                ]),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5), width: 1.5),
                  ),
                  onPressed: busy ? null : () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: busy ? null : () => showDeleteAccountDialog(context, usesPassword: usesPassword),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Delete account'),
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppConstants.appName} v${AppConstants.version} · Made with ♥ for pets',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) => showAboutDialog(
        context: context,
        applicationName: AppConstants.appName,
        applicationVersion: 'Version ${AppConstants.version}',
        applicationIcon: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset('assets/images/app_icon.png', width: 56, height: 56),
        ),
        applicationLegalese: 'Healthy pets, happy homes.',
        children: const [
          SizedBox(height: 16),
          Text('Track vaccinations, vet appointments, medications, documents and weight '
              'for all your pets, with reminders that work even offline.'),
        ],
      );

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Log out?',
      message: 'You will need to sign in again to access your pets.',
      confirmLabel: 'Log out',
      icon: Icons.logout_rounded,
      accent: FeatureAccent.settings,
    );
    if (confirmed) await ref.read(accountControllerProvider.notifier).signOut();
  }
}

/// Floating gradient card: avatar, name, contact details and quick stats.
class _ProfileHero extends ConsumerWidget {
  const _ProfileHero({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = profile;
    final name = (p?.fullName.isNotEmpty ?? false) ? p!.fullName : 'PetCare user';
    final pets = ref.watch(petsProvider).value?.length ?? 0;
    final clinics = ref.watch(clinicsProvider).value?.length ?? 0;
    final alerts = ref.watch(dashboardProvider).value?.alerts.length ?? 0;
    final white70 = Colors.white.withValues(alpha: 0.85);

    Widget detail(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(icon, size: 15, color: white70),
              const SizedBox(width: 6),
              Flexible(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: white70)),
              ),
            ],
          ),
        );

    return GradientHeader(
      floating: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push(AppRoutes.profileEdit),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: ProfileAvatar(initials: p?.initials ?? '', photoUrl: p?.photoUrl, radius: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    if (p != null && p.email.isNotEmpty) detail(Icons.mail_outline, p.email),
                    if (p?.phone != null) detail(Icons.phone_outlined, p!.phone!),
                    if (p?.city != null) detail(Icons.location_on_outlined, p!.city!),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (p?.memberSince != null)
                Expanded(
                  child: Text(
                    'Member since ${DateFormat.yMMMM().format(p!.memberSince!)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: white70),
                  ),
                )
              else
                const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.tealDeep,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                ),
                onPressed: () => context.push(AppRoutes.profileEdit),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              HeaderStat(value: '$pets', label: pets == 1 ? 'Pet' : 'Pets', icon: Icons.pets),
              const SizedBox(width: 10),
              HeaderStat(value: '$clinics', label: clinics == 1 ? 'Clinic' : 'Clinics', icon: Icons.local_hospital_outlined),
              const SizedBox(width: 10),
              HeaderStat(value: '$alerts', label: alerts == 1 ? 'Alert' : 'Alerts', icon: Icons.notifications_active_outlined),
            ],
          ),
        ],
      ),
    );
  }
}
