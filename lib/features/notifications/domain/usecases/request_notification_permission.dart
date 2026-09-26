import '../repositories/push_messaging_repository.dart';
import '../repositories/reminder_scheduler.dart';

/// Asks for local-notification and push permission.
class RequestNotificationPermission {
  const RequestNotificationPermission(this._scheduler, this._push);

  final ReminderScheduler _scheduler;
  final PushMessagingRepository _push;

  Future<bool> call() async {
    final local = await _scheduler.requestPermission();
    await _push.requestPermission();
    return local;
  }
}
