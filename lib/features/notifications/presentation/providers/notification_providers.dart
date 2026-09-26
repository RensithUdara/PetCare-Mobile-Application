import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart' hide NotificationSettings;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/storage/shared_preferences_provider.dart';
import '../../../../core/utils/clock.dart';
import '../../../appointments/presentation/providers/appointment_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../medications/presentation/providers/medication_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../../vaccinations/presentation/providers/vaccination_providers.dart';
import '../../data/repositories/firebase_push_messaging_repository.dart';
import '../../data/repositories/local_reminder_scheduler.dart';
import '../../data/repositories/notification_settings_repository_impl.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../../domain/repositories/push_messaging_repository.dart';
import '../../domain/repositories/reminder_scheduler.dart';
import '../../domain/usecases/apply_reminder_plan.dart';
import '../../domain/usecases/clear_reminders.dart';
import '../../domain/usecases/notification_settings_usecases.dart';
import '../../domain/usecases/push_device_usecases.dart';
import '../../domain/usecases/request_notification_permission.dart';
import '../../domain/usecases/show_test_notification.dart';
import '../../domain/usecases/watch_reminder_plan.dart';

// ── Data ────────────────────────────────────────────────────────────────
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => LocalReminderScheduler(FlutterLocalNotificationsPlugin()),
);

final notificationSettingsRepositoryProvider = Provider<NotificationSettingsRepository>(
  (ref) => NotificationSettingsRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final pushMessagingRepositoryProvider = Provider<PushMessagingRepository>(
  (ref) => FirebasePushMessagingRepository(FirebaseMessaging.instance),
);

final deviceRegistryProvider = Provider<DeviceRegistry>(
  (ref) => FirestoreDeviceRegistry(FirebaseFirestore.instance),
);

// ── Use cases ───────────────────────────────────────────────────────────
final watchReminderPlanProvider = Provider(
  (ref) => WatchReminderPlan(
    ref.watch(petRepositoryProvider),
    ref.watch(appointmentRepositoryProvider),
    ref.watch(vaccinationRepositoryProvider),
    ref.watch(medicationRepositoryProvider),
    ref.watch(clockProvider),
  ),
);
final applyReminderPlanProvider =
    Provider((ref) => ApplyReminderPlan(ref.watch(reminderSchedulerProvider)));
final clearRemindersProvider =
    Provider((ref) => ClearReminders(ref.watch(reminderSchedulerProvider)));
final requestNotificationPermissionProvider = Provider(
  (ref) => RequestNotificationPermission(
    ref.watch(reminderSchedulerProvider),
    ref.watch(pushMessagingRepositoryProvider),
  ),
);
final showTestNotificationProvider =
    Provider((ref) => ShowTestNotification(ref.watch(reminderSchedulerProvider)));
final getNotificationSettingsProvider =
    Provider((ref) => GetNotificationSettings(ref.watch(notificationSettingsRepositoryProvider)));
final saveNotificationSettingsProvider =
    Provider((ref) => SaveNotificationSettings(ref.watch(notificationSettingsRepositoryProvider)));
final registerPushDeviceProvider = Provider(
  (ref) => RegisterPushDevice(
    ref.watch(pushMessagingRepositoryProvider),
    ref.watch(deviceRegistryProvider),
    ref.watch(clockProvider),
  ),
);
final unregisterPushDeviceProvider = Provider(
  (ref) => UnregisterPushDevice(
    ref.watch(pushMessagingRepositoryProvider),
    ref.watch(deviceRegistryProvider),
  ),
);

// ── State ───────────────────────────────────────────────────────────────
class NotificationSettingsController extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() => ref.read(getNotificationSettingsProvider)();

  Future<void> update(NotificationSettings settings) async {
    state = settings;
    await ref.read(saveNotificationSettingsProvider)(settings);
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsController, NotificationSettings>(
  NotificationSettingsController.new,
);

/// The reminders that should currently be scheduled on this device.
final reminderPlanProvider = StreamProvider<List<PlannedReminder>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(watchReminderPlanProvider)(
    ownerId: uid,
    settings: ref.watch(notificationSettingsProvider),
    formatTime: DateFormat.jm().format,
  );
});
