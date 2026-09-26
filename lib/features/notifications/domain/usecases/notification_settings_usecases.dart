import '../entities/notification_settings.dart';
import '../repositories/notification_settings_repository.dart';

class GetNotificationSettings {
  const GetNotificationSettings(this._repository);

  final NotificationSettingsRepository _repository;

  NotificationSettings call() => _repository.load();
}

class SaveNotificationSettings {
  const SaveNotificationSettings(this._repository);

  final NotificationSettingsRepository _repository;

  Future<void> call(NotificationSettings settings) => _repository.save(settings);
}
