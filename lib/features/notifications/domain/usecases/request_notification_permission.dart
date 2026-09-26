import '../repositories/push_messaging_repository.dart';
import '../repositories/reminder_scheduler.dart';

/// Asks for local-notification and push permission.
class RequestNotificationPermission {
  const RequestNotificationPermission(this._scheduler, this._push);

  final ReminderScheduler _scheduler;
  final PushMessagingRepository _push;

  /// Whether local notifications are allowed. Push permission is best
  /// effort: it can fail without Google Play services (e.g. emulators) and
  /// must not block local reminders.
  Future<bool> call() async {
    final local = await _scheduler.requestPermission();
    try {
      await _push.requestPermission();
    } catch (_) {
      // Push unavailable on this device; local reminders still work.
    }
    return local;
  }
}
