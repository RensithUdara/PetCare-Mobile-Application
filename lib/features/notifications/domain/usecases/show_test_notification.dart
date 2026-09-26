import '../repositories/reminder_scheduler.dart';

/// Lets the user check that notifications reach them.
class ShowTestNotification {
  const ShowTestNotification(this._scheduler);

  final ReminderScheduler _scheduler;

  Future<void> call() => _scheduler.showNow(
        title: 'PetCare reminders are on 🐾',
        body: 'This is how vaccination, appointment and medication reminders will look.',
      );
}
