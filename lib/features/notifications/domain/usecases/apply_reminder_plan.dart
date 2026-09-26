import '../entities/reminder.dart';
import '../repositories/reminder_scheduler.dart';

/// Makes the device's pending notifications match [plan].
class ApplyReminderPlan {
  const ApplyReminderPlan(this._scheduler);

  final ReminderScheduler _scheduler;

  Future<void> call(List<PlannedReminder> plan) => _scheduler.replaceAll(plan);
}
