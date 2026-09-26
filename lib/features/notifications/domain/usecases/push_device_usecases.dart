import '../repositories/push_messaging_repository.dart';

/// Registers this device's push token and marks it as scheduling reminders
/// locally. Returns the token, or `null` if push is unavailable.
class RegisterPushDevice {
  const RegisterPushDevice(this._push, this._registry, this._now);

  final PushMessagingRepository _push;
  final DeviceRegistry _registry;
  final DateTime Function() _now;

  Future<String?> call(String ownerId) async {
    final token = await _push.getToken();
    if (token == null) return null;
    await _registry.register(ownerId: ownerId, token: token, lastSyncedAt: _now());
    return token;
  }
}

/// Removes this device's registration (call before signing out, while the
/// user is still authorised to write their data).
class UnregisterPushDevice {
  const UnregisterPushDevice(this._push, this._registry);

  final PushMessagingRepository _push;
  final DeviceRegistry _registry;

  Future<void> call(String ownerId) async {
    final token = await _push.getToken();
    if (token != null) await _registry.unregister(ownerId: ownerId, token: token);
  }
}
