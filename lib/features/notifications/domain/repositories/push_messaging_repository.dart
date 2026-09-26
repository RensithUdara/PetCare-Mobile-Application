/// A push message received while the app is in the foreground.
class PushMessage {
  const PushMessage({this.title, this.body, this.payload});

  final String? title;
  final String? body;

  /// A `ReminderTarget` payload (`"vaccination:<id>"`), if any.
  final String? payload;
}

/// Remote push (FCM) on this device.
abstract interface class PushMessagingRepository {
  Future<bool> requestPermission();

  Future<String?> getToken();

  Stream<String> get tokenRefreshes;

  Stream<PushMessage> get foregroundMessages;

  /// Payloads of push notifications the user tapped.
  Stream<String> get openedPayloads;

  /// Payload of the push notification that launched the app, if any.
  Future<String?> initialPayload();
}

/// Where this user's devices are registered for server-side reminders.
abstract interface class DeviceRegistry {
  /// Records [token] and when this device last scheduled reminders locally.
  /// The server only pushes reminders to users whose devices have not
  /// synced recently, so it never duplicates local notifications.
  Future<void> register({
    required String ownerId,
    required String token,
    required DateTime lastSyncedAt,
  });

  Future<void> unregister({required String ownerId, required String token});
}
