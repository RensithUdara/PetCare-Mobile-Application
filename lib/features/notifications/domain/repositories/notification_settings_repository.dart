import '../entities/notification_settings.dart';

abstract interface class NotificationSettingsRepository {
  NotificationSettings load();

  Future<void> save(NotificationSettings settings);
}
