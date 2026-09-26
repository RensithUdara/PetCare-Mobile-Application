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
  late FakeReminderScheduler scheduler;
  late FakePushMessaging push;

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    scheduler = FakeReminderScheduler();
    push = FakePushMessaging();
    await pumpScreen(tester, const NotificationSettingsScreen(), overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentUserIdProvider.overrideWithValue(null),
      reminderSchedulerProvider.overrideWithValue(scheduler),
      pushMessagingRepositoryProvider.overrideWithValue(push),
      deviceRegistryProvider.overrideWithValue(FakeDeviceRegistry()),
    ]);
  }

  SwitchListTile tile(WidgetTester tester, String title) =>
      tester.widget(find.widgetWithText(SwitchListTile, title));

  testWidgets('category switches persist and follow the master switch', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Medication reminders'));
    await tester.pump();
    expect(NotificationSettingsRepositoryImpl(prefs).load().medications, isFalse);

    await tester.tap(find.text('Allow reminders'));
    await tester.pump();
    expect(find.text('Reminders are paused'), findsOneWidget);
    expect(tile(tester, 'Vaccination reminders').onChanged, isNull, reason: 'disabled');
    expect(tile(tester, 'Vaccination reminders').value, isFalse);
  });

  testWidgets('test notification asks permission and shows a notification', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Send test notification'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(scheduler.permissionRequests, 1);
    expect(scheduler.shown.single.title, contains('reminders are on'));
    expect(find.text('Test notification sent'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('test notification still works when push is unavailable', (tester) async {
    await pump(tester);
    push.failPermission = true; // e.g. no Google Play services on an emulator

    await tester.tap(find.text('Send test notification'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(scheduler.shown, hasLength(1));
    await tester.pumpAndSettle();
  });

  testWidgets('explains when notifications are blocked', (tester) async {
    await pump(tester);
    scheduler.grantPermission = false;

    await tester.tap(find.text('Send test notification'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications are blocked'), findsOneWidget);
    expect(scheduler.shown, isEmpty);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });
}
