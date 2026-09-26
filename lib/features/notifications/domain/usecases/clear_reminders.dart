import '../repositories/reminder_scheduler.dart';

class ClearReminders {
  const ClearReminders(this._scheduler);

  final ReminderScheduler _scheduler;

  Future<void> call() => _scheduler.cancelAll();
}
