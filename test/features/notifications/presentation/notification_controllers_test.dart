import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/storage/shared_preferences_provider.dart';
import 'package:petcare/core/utils/clock.dart';
import 'package:petcare/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/medications/domain/entities/dose_time.dart';
import 'package:petcare/features/medications/domain/entities/medication.dart';
import 'package:petcare/features/medications/presentation/providers/medication_providers.dart';
import 'package:petcare/features/notifications/data/repositories/notification_settings_repository_impl.dart';
import 'package:petcare/features/notifications/domain/entities/notification_settings.dart';
import 'package:petcare/features/notifications/domain/repositories/push_messaging_repository.dart';
import 'package:petcare/features/notifications/presentation/controllers/notification_events_controller.dart';
import 'package:petcare/features/notifications/presentation/controllers/reminder_sync_controller.dart';
import 'package:petcare/features/notifications/presentation/providers/notification_providers.dart';
import 'package:petcare/features/pets/domain/entities/pet.dart';
import 'package:petcare/features/pets/presentation/providers/pet_providers.dart';
import 'package:petcare/features/vaccinations/presentation/providers/vaccination_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_appointment_repository.dart';
import '../../../helpers/fake_medication_repository.dart';
import '../../../helpers/fake_notifications.dart';
import '../../../helpers/fake_pet_repository.dart';
import '../../../helpers/fake_vaccination_repository.dart';

void main() {
  final now = DateTime(2026, 9, 26, 12);
  late FakeReminderScheduler scheduler;
  late FakePushMessaging push;
  late FakeDeviceRegistry registry;
  late FakeMedicationRepository medications;
  late SharedPreferences prefs;

  final vitamin = Medication(
    id: 'vit',
    ownerId: 'u1',
    petId: 'bruno',
    name: 'Vitamin',
    dosage: '1 tablet',
    startDate: DateTime(2026, 9, 1),
    doseTimes: const [DoseTime(20, 0)],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    scheduler = FakeReminderScheduler();
    push = FakePushMessaging();
    registry = FakeDeviceRegistry();
    medications = FakeMedicationRepository([vitamin]);
  });

  ProviderContainer container({String? uid = 'u1'}) {
    final c = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentUserIdProvider.overrideWithValue(uid),
      clockProvider.overrideWithValue(() => now),
      petRepositoryProvider.overrideWithValue(FakePetRepository(const [
        Pet(id: 'bruno', ownerId: 'u1', name: 'Bruno', species: PetSpecies.dog),
      ])),
      appointmentRepositoryProvider.overrideWithValue(FakeAppointmentRepository()),
      vaccinationRepositoryProvider.overrideWithValue(FakeVaccinationRepository()),
      medicationRepositoryProvider.overrideWithValue(medications),
      reminderSchedulerProvider.overrideWithValue(scheduler),
      pushMessagingRepositoryProvider.overrideWithValue(push),
      deviceRegistryProvider.overrideWithValue(registry),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  group('ReminderSyncController', () {
    test('schedules the plan, asks permission once and registers the device', () async {
      final c = container();
      c.listen(reminderSyncControllerProvider, (_, _) {});
      await pumpEventQueue();

      expect(scheduler.scheduled, isNotEmpty);
      expect(scheduler.scheduled!.first.body, 'It’s time for Bruno’s Vitamin (1 tablet).');
      expect(scheduler.permissionRequests, 1);
      expect(c.read(reminderSyncControllerProvider).scheduledCount, scheduler.scheduled!.length);
      expect(registry.registrations.single.token, 'token-1');

      // A data change re-plans without asking again or re-registering.
      await medications.save(vitamin.copyWith(id: 'vit2', name: 'Fish oil'));
      await pumpEventQueue();
      expect(scheduler.scheduled!.any((r) => r.body.contains('Fish oil')), isTrue);
      expect(scheduler.permissionRequests, 1);
      expect(registry.registrations, hasLength(1));
    });

    test('turning reminders off clears the schedule', () async {
      final c = container();
      c.listen(reminderSyncControllerProvider, (_, _) {});
      await pumpEventQueue();
      expect(scheduler.scheduled, isNotEmpty);

      await c
          .read(notificationSettingsProvider.notifier)
          .update(const NotificationSettings(enabled: false));
      await pumpEventQueue();

      expect(scheduler.scheduled, isEmpty);
      expect(NotificationSettingsRepositoryImpl(prefs).load().enabled, isFalse,
          reason: 'setting persisted');
    });

    test('prepareSignOut unregisters the device and cancels reminders', () async {
      final c = container();
      c.listen(reminderSyncControllerProvider, (_, _) {});
      await pumpEventQueue();

      await c.read(reminderSyncControllerProvider.notifier).prepareSignOut();

      expect(registry.unregistered, ['u1/token-1']);
      expect(scheduler.cancelAllCalls, 1);
      expect(scheduler.scheduled, isEmpty);
    });

    test('signed out: nothing is scheduled or registered', () async {
      final c = container(uid: null);
      c.listen(reminderSyncControllerProvider, (_, _) {});
      await pumpEventQueue();

      expect(scheduler.scheduled, isEmpty);
      expect(scheduler.permissionRequests, 0);
      expect(registry.registrations, isEmpty);
    });
  });

  group('NotificationEventsController', () {
    test('maps payloads to Home-tab routes', () {
      expect(routeForPayload('vaccination:v1'), '/home/vaccination/v1');
      expect(routeForPayload('appointment:a1'), '/home/appointment/a1');
      expect(routeForPayload('medication:m1'), '/home/medication/m1');
      expect(routeForPayload('garbage'), isNull);
    });

    test('exposes the launch notification and later taps as pending routes', () async {
      scheduler.launch = 'medication:vit';
      final c = container();
      final routes = <String?>[];
      c.listen(notificationEventsControllerProvider, (_, next) => routes.add(next));
      await pumpEventQueue();
      expect(routes.last, '/home/medication/vit');

      c.read(notificationEventsControllerProvider.notifier).consume();
      push.opened.add('appointment:a1');
      await pumpEventQueue();
      expect(routes.last, '/home/appointment/a1');
    });

    test('shows foreground push messages as local notifications', () async {
      final c = container();
      c.listen(notificationEventsControllerProvider, (_, _) {});
      await pumpEventQueue();

      push.foreground.add(
        const PushMessage(title: 'Vaccination reminder', body: 'Due soon', payload: 'vaccination:v1'),
      );
      await pumpEventQueue();

      expect(scheduler.shown.single.payload, 'vaccination:v1');
    });
  });
}
