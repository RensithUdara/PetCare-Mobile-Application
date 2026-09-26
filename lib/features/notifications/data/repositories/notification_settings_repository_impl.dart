import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_settings_repository.dart';

class NotificationSettingsRepositoryImpl implements NotificationSettingsRepository {
  NotificationSettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'notifications.';

  bool _get(String key) => _prefs.getBool('$_prefix$key') ?? true;

  @override
  NotificationSettings load() => NotificationSettings(
        enabled: _get('enabled'),
        vaccinations: _get('vaccinations'),
        appointments: _get('appointments'),
        medications: _get('medications'),
      );

  @override
  Future<void> save(NotificationSettings s) async {
    await Future.wait([
      _prefs.setBool('${_prefix}enabled', s.enabled),
      _prefs.setBool('${_prefix}vaccinations', s.vaccinations),
      _prefs.setBool('${_prefix}appointments', s.appointments),
      _prefs.setBool('${_prefix}medications', s.medications),
    ]);
  }
}
