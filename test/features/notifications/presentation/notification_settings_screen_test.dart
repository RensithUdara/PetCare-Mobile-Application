import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/storage/shared_preferences_provider.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/notifications/data/repositories/notification_settings_repository_impl.dart';
import 'package:petcare/features/notifications/presentation/providers/notification_providers.dart';
import 'package:petcare/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_notifications.dart';
import '../../../helpers/pump_screen.dart';

void main() {
  late SharedPreferences prefs;

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await pumpScreen(
      tester,
      const NotificationSettingsScreen(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentUserIdProvider.overrideWithValue(null),
        reminderSchedulerProvider.overrideWithValue(FakeReminderScheduler()),
        pushMessagingRepositoryProvider.overrideWithValue(FakePushMessaging()),
        deviceRegistryProvider.overrideWithValue(FakeDeviceRegistry()),
      ],
    );
  }

  SwitchListTile tile(WidgetTester tester, String title) =>
      tester.widget(find.widgetWithText(SwitchListTile, title));

  testWidgets('category switches persist and follow the master switch', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Medication reminders'));
    await tester.pump();
    expect(
      NotificationSettingsRepositoryImpl(prefs).load().medications,
      isFalse,
    );

    await tester.tap(find.text('Allow reminders'));
    await tester.pump();
    expect(
      tile(tester, 'Vaccination reminders').onChanged,
      isNull,
      reason: 'disabled',
    );
    expect(tile(tester, 'Vaccination reminders').value, isFalse);

    expect(find.text('Reminders are paused'), findsNothing);
    expect(find.text('Test your reminders'), findsNothing);
    expect(find.text('Send test notification'), findsNothing);
  });
}
