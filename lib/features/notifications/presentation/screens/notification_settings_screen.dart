import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/logic/reminder_planner.dart';
import '../controllers/reminder_sync_controller.dart';
import '../providers/notification_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  static const _descriptions = {
    ReminderCategory.vaccination: 'Before a vaccination is due (timing set per record)',
    ReminderCategory.appointment: 'Before vet appointments (timing set per appointment)',
    ReminderCategory.medication: 'At each dose time for active medications',
  };

  static const _accents = {
    ReminderCategory.vaccination: FeatureAccent.vaccinations,
    ReminderCategory.appointment: FeatureAccent.appointments,
    ReminderCategory.medication: FeatureAccent.medications,
  };

  static const _icons = {
    ReminderCategory.vaccination: Icons.vaccines_outlined,
    ReminderCategory.appointment: Icons.event_outlined,
    ReminderCategory.medication: Icons.medication_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);
    final sync = ref.watch(reminderSyncControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const BrandAppBar.page(title: 'Notifications'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Allow reminders'),
              subtitle: const Text('Turn off to pause all PetCare reminders'),
              value: settings.enabled,
              onChanged: (v) => controller.update(settings.copyWith(enabled: v)),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final category in ReminderCategory.values)
                  SwitchListTile(
                    secondary: IconBadge(icon: _icons[category]!, accent: _accents[category]!, size: 40),
                    title: Text(category.label),
                    subtitle: Text(_descriptions[category]!),
                    value: settings.enabled && settings.allows(category),
                    onChanged: settings.enabled
                        ? (v) => controller.update(settings.withCategory(category, v))
                        : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (sync.permissionGranted == false)
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.notifications_off_outlined,
                    color: theme.colorScheme.onErrorContainer),
                title: Text('Notifications are blocked',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                subtitle: Text(
                  'Allow notifications for PetCare in your device settings to receive reminders.',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(
              settings.enabled
                  ? '${sync.scheduledCount} reminder${sync.scheduledCount == 1 ? '' : 's'} '
                      'scheduled on this device'
                  : 'Reminders are paused',
            ),
            subtitle: const Text(
              'Medication doses are scheduled $medicationHorizonDays days ahead and '
              'refreshed whenever you open the app.',
            ),
          ),
          const SizedBox(height: 16),
          const _TestNotificationCard(),
        ],
      ),
    );
  }
}

/// Sends a notification right away so the user can check reminders reach them.
class _TestNotificationCard extends ConsumerStatefulWidget {
  const _TestNotificationCard();

  @override
  ConsumerState<_TestNotificationCard> createState() => _TestNotificationCardState();
}

class _TestNotificationCardState extends ConsumerState<_TestNotificationCard> {
  bool _busy = false;

  Future<void> _send() async {
    setState(() => _busy = true);
    bool granted;
    try {
      granted = await ref.read(requestNotificationPermissionProvider)();
      if (granted) await ref.read(showTestNotificationProvider)();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send a test notification.')),
        );
      }
      return;
    }
    if (!mounted) return;
    // Stop the spinner before showing the result.
    setState(() => _busy = false);
    if (granted) {
      await showSuccessDialog(
        context,
        title: 'Test notification sent',
        message: 'Check your notification shade — it should appear in a few seconds.',
      );
    } else {
      await showConfirmDialog(
        context,
        title: 'Notifications are blocked',
        message: 'Allow notifications for PetCare in your phone’s Settings → Apps → PetCare → '
            'Notifications, then try again.',
        confirmLabel: 'OK',
        cancelLabel: 'Close',
        icon: Icons.notifications_off_outlined,
        accent: FeatureAccent.emergency,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconBadge(icon: Icons.notifications_active_outlined, accent: FeatureAccent.appointments),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Test your reminders',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    Text('Send a notification now to check it reaches this phone.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _busy ? null : _send,
            icon: _busy
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Icon(Icons.send_rounded),
            label: const Text('Send test notification'),
          ),
        ],
      ),
    );
  }
}
