import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_providers.dart';

/// UI state (busy / error) for appointment actions.
class AppointmentEditorController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the id on success, `null` on failure.
  Future<String?> save(Appointment appointment) => _run(
        () => ref.read(saveAppointmentProvider)(ownerId: _uid(), appointment: appointment),
      );

  Future<bool> setStatus(Appointment appointment, AppointmentStatus status) async {
    final result = await _run(() async {
      await ref.read(updateAppointmentStatusProvider)(appointment: appointment, status: status);
      return appointment.id;
    });
    return result != null;
  }

  Future<bool> delete(String appointmentId) async {
    final result = await _run(() async {
      await ref.read(deleteAppointmentProvider)(ownerId: _uid(), appointmentId: appointmentId);
      return appointmentId;
    });
    return result != null;
  }

  String _uid() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) throw const Failure('You are signed out. Please sign in again.');
    return uid;
  }

  Future<String?> _run(Future<String> Function() action) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      final id = await action();
      if (ref.mounted) state = const AsyncData(null);
      return id;
    } catch (error, stack) {
      final failure = error is Failure
          ? error
          : Failure('Something went wrong. Please try again.', cause: error);
      if (ref.mounted) state = AsyncError(failure, stack);
      return null;
    }
  }
}

final appointmentEditorControllerProvider =
    NotifierProvider.autoDispose<AppointmentEditorController, AsyncValue<void>>(
  AppointmentEditorController.new,
);
