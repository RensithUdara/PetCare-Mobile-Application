import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'features/authentication/presentation/providers/auth_providers.dart';
import 'features/notifications/presentation/controllers/notification_events_controller.dart';
import 'features/notifications/presentation/controllers/reminder_sync_controller.dart';

class PetCareApp extends ConsumerWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep reminders in sync for the whole session (listen, not watch, so
    // sync progress never rebuilds the app).
    ref.listen(reminderSyncControllerProvider, (_, _) {});

    // Open the screen for a tapped notification once the user is signed in.
    void openPendingNotification() {
      final route = ref.read(notificationEventsControllerProvider);
      if (route == null || ref.read(currentUserIdProvider) == null) return;
      ref.read(notificationEventsControllerProvider.notifier).consume();
      // Let auth redirects settle first.
      Future.microtask(() => ref.read(appRouterProvider).push(route));
    }

    ref.listen(notificationEventsControllerProvider, (_, _) => openPendingNotification());
    ref.listen(currentUserIdProvider, (_, _) => openPendingNotification());

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

/// Shown instead of the app when Firebase failed to initialize —
/// typically because `flutterfire configure` has not been run yet.
class FirebaseSetupRequiredApp extends StatelessWidget {
  const FirebaseSetupRequiredApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.cloud_off, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Firebase is not configured',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Run these commands in the project folder, then restart the app:\n\n'
                '  dart pub global activate flutterfire_cli\n'
                '  flutterfire configure',
              ),
              const SizedBox(height: 16),
              Text('$error', style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ),
    );
  }
}
