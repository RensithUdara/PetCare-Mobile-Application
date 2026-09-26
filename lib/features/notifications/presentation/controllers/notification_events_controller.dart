import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/reminder.dart';
import '../providers/notification_providers.dart';

/// Screen to open for a notification payload (inside the Home tab).
String? routeForPayload(String? payload) {
  final target = ReminderTarget.tryParse(payload);
  if (target == null) return null;
  return switch (target.category) {
    ReminderCategory.vaccination => AppRoutes.homeVaccination(target.sourceId),
    ReminderCategory.appointment => AppRoutes.homeAppointment(target.sourceId),
    ReminderCategory.medication => AppRoutes.homeMedication(target.sourceId),
  };
}

/// Collects notification taps (local and push, including the one that
/// launched the app) and shows foreground push messages.
///
/// State is the route waiting to be opened; the app navigates once the
/// user is signed in and then calls [consume].
class NotificationEventsController extends Notifier<String?> {
  @override
  String? build() {
    final scheduler = ref.watch(reminderSchedulerProvider);
    final push = ref.watch(pushMessagingRepositoryProvider);

    final subs = <StreamSubscription<Object?>>[
      scheduler.tappedPayloads.listen(_open),
      push.openedPayloads.listen(_open),
      push.foregroundMessages.listen((m) {
        // FCM doesn't display notifications while the app is open.
        scheduler
            .showNow(title: m.title ?? 'PetCare', body: m.body ?? '', payload: m.payload)
            .catchError((Object e) => debugPrint('Could not show push: $e'));
      }),
    ];
    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
    });

    Future(() async {
      try {
        _open(await scheduler.launchPayload() ?? await push.initialPayload());
      } catch (e) {
        debugPrint('Could not read launch notification: $e');
      }
    });
    return null;
  }

  void _open(String? payload) {
    final route = routeForPayload(payload);
    if (route != null && ref.mounted) state = route;
  }

  /// Marks the pending route as handled.
  void consume() => state = null;
}

final notificationEventsControllerProvider =
    NotifierProvider<NotificationEventsController, String?>(NotificationEventsController.new);
