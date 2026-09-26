import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_scheduler.dart';

/// [ReminderScheduler] backed by `flutter_local_notifications`.
///
/// Uses inexact alarms (no exact-alarm permission needed); Android may
/// deliver them a few minutes late while the device is idle.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final _taps = StreamController<String>.broadcast();
  Future<void>? _initialized;

  static const _channels = {
    ReminderCategory.vaccination: ('vaccinations', 'Vaccinations', 'Vaccination due-date reminders'),
    ReminderCategory.appointment: ('appointments', 'Appointments', 'Upcoming vet appointments'),
    ReminderCategory.medication: ('medications', 'Medications', 'Medication dose reminders'),
  };
  static const _generalChannel = ('general', 'General', 'Other PetCare notifications');

  Future<void> _ensureInitialized() => _initialized ??= _initialize();

  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      // Unknown zone id: fall back to UTC rather than failing to schedule.
      debugPrint('Could not resolve local timezone: $e');
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested explicitly via requestPermission().
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _taps.add(payload);
      },
    );
  }

  NotificationDetails _details((String, String, String) channel) => NotificationDetails(
        android: AndroidNotificationDetails(
          channel.$1,
          channel.$2,
          channelDescription: channel.$3,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final android =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await _ensureInitialized();
    // Pending only: never dismiss notifications already in the tray.
    await _plugin.cancelAllPendingNotifications();
    final now = DateTime.now();
    for (final r in reminders) {
      if (!r.fireAt.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        scheduledDate: tz.TZDateTime.from(r.fireAt, tz.local),
        notificationDetails: _details(_channels[r.target.category]!),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: r.target.payload,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAllPendingNotifications();
  }

  @override
  Future<void> showNow({required String title, required String body, String? payload}) async {
    await _ensureInitialized();
    final category = ReminderTarget.tryParse(payload)?.category;
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title: title,
      body: body,
      notificationDetails: _details(category == null ? _generalChannel : _channels[category]!),
      payload: payload,
    );
  }

  @override
  Stream<String> get tappedPayloads => _taps.stream;

  @override
  Future<String?> launchPayload() async {
    await _ensureInitialized();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }
}
