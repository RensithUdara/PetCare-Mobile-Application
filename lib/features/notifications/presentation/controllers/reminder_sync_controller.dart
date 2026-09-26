import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/reminder.dart';
import '../providers/notification_providers.dart';

@immutable
class ReminderSyncState {
  const ReminderSyncState({this.scheduledCount = 0, this.permissionGranted, this.lastSyncedAt});

  final int scheduledCount;

  /// `null` until permission has been requested this session.
  final bool? permissionGranted;
  final DateTime? lastSyncedAt;

  ReminderSyncState copyWith({int? scheduledCount, bool? permissionGranted, DateTime? lastSyncedAt}) =>
      ReminderSyncState(
        scheduledCount: scheduledCount ?? this.scheduledCount,
        permissionGranted: permissionGranted ?? this.permissionGranted,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}

/// Keeps the device's scheduled notifications in line with the reminder
/// plan, and tells the server this device handles reminders locally.
///
/// Watched once from the app root so it lives for the whole session.
class ReminderSyncController extends Notifier<ReminderSyncState> {
  /// Device registration is refreshed at most this often.
  static const registrationInterval = Duration(hours: 6);

  DateTime? _registeredAt;
  String? _registeredFor;

  @override
  ReminderSyncState build() {
    ref.listen(
      reminderPlanProvider,
      (_, next) => next.whenData(_apply),
      fireImmediately: true,
    );
    return const ReminderSyncState();
  }

  Future<void> _apply(List<PlannedReminder> plan) async {
    try {
      if (plan.isNotEmpty && state.permissionGranted == null) {
        final granted = await ref.read(requestNotificationPermissionProvider)();
        if (!ref.mounted) return;
        state = state.copyWith(permissionGranted: granted);
      }
      await ref.read(applyReminderPlanProvider)(plan);
      if (!ref.mounted) return;
      final now = ref.read(clockProvider)();
      state = state.copyWith(scheduledCount: plan.length, lastSyncedAt: now);
      await _registerDevice(now);
    } catch (e, st) {
      // Reminders are best effort; never crash the app over them.
      debugPrint('Reminder sync failed: $e\n$st');
    }
  }

  Future<void> _registerDevice(DateTime now) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final fresh = _registeredFor == uid &&
        _registeredAt != null &&
        now.difference(_registeredAt!) < registrationInterval;
    if (fresh) return;
    if (await ref.read(registerPushDeviceProvider)(uid) != null) {
      _registeredAt = now;
      _registeredFor = uid;
    }
  }

  /// Call before signing out: removes the device registration while the
  /// user can still write it, and clears scheduled reminders.
  Future<void> prepareSignOut() async {
    final uid = ref.read(currentUserIdProvider);
    try {
      if (uid != null) await ref.read(unregisterPushDeviceProvider)(uid);
    } catch (e) {
      debugPrint('Could not unregister device: $e');
    }
    await ref.read(clearRemindersProvider)();
    _registeredAt = null;
    _registeredFor = null;
    if (ref.mounted) state = const ReminderSyncState();
  }
}

final reminderSyncControllerProvider =
    NotifierProvider<ReminderSyncController, ReminderSyncState>(ReminderSyncController.new);
