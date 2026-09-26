import '../entities/reminder.dart';

/// Schedules notifications on this device.
abstract interface class ReminderScheduler {
  /// Asks the OS for permission to post notifications. Returns whether
  /// notifications are allowed.
  Future<bool> requestPermission();

  /// Replaces every pending (not yet shown) reminder with [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders);

  /// Cancels every pending reminder (e.g. on sign-out).
  Future<void> cancelAll();

  /// Shows a notification immediately.
  Future<void> showNow({required String title, required String body, String? payload});

  /// Payloads of notifications the user tapped while the app was running.
  Stream<String> get tappedPayloads;

  /// Payload of the notification that launched the app, if any.
  Future<String?> launchPayload();
}
