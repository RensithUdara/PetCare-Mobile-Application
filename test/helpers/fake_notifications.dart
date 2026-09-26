import 'dart:async';

import 'package:petcare/features/notifications/domain/entities/reminder.dart';
import 'package:petcare/features/notifications/domain/repositories/push_messaging_repository.dart';
import 'package:petcare/features/notifications/domain/repositories/reminder_scheduler.dart';

class FakeReminderScheduler implements ReminderScheduler {
  bool grantPermission = true;
  int permissionRequests = 0;
  int cancelAllCalls = 0;
  String? launch;
  List<PlannedReminder>? scheduled;
  final shown = <({String title, String body, String? payload})>[];
  final taps = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grantPermission;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async => scheduled = reminders;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled = const [];
  }

  @override
  Future<void> showNow({required String title, required String body, String? payload}) async =>
      shown.add((title: title, body: body, payload: payload));

  @override
  Stream<String> get tappedPayloads => taps.stream;

  @override
  Future<String?> launchPayload() async => launch;
}

class FakePushMessaging implements PushMessagingRepository {
  String? token = 'token-1';
  String? initial;
  final foreground = StreamController<PushMessage>.broadcast();
  final opened = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Stream<PushMessage> get foregroundMessages => foreground.stream;

  @override
  Stream<String> get openedPayloads => opened.stream;

  @override
  Future<String?> initialPayload() async => initial;
}

class FakeDeviceRegistry implements DeviceRegistry {
  final registrations = <({String ownerId, String token, DateTime lastSyncedAt})>[];
  final unregistered = <String>[];

  @override
  Future<void> register({
    required String ownerId,
    required String token,
    required DateTime lastSyncedAt,
  }) async =>
      registrations.add((ownerId: ownerId, token: token, lastSyncedAt: lastSyncedAt));

  @override
  Future<void> unregister({required String ownerId, required String token}) async =>
      unregistered.add('$ownerId/$token');
}
