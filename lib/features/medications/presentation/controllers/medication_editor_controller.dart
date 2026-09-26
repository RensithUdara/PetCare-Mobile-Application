import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/medication.dart';
import '../providers/medication_providers.dart';

/// UI state (busy / error) for medication actions.
class MedicationEditorController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns the id on success, `null` on failure.
  Future<String?> save(Medication medication) => _run(
        () => ref.read(saveMedicationProvider)(ownerId: _uid(), medication: medication),
      );

  Future<bool> stop(Medication medication) async {
    final result = await _run(() async {
      await ref.read(stopMedicationProvider)(medication);
      return medication.id;
    });
    return result != null;
  }

  Future<bool> delete(String medicationId) async {
    final result = await _run(() async {
      await ref.read(deleteMedicationProvider)(ownerId: _uid(), medicationId: medicationId);
      return medicationId;
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

final medicationEditorControllerProvider =
    NotifierProvider.autoDispose<MedicationEditorController, AsyncValue<void>>(
  MedicationEditorController.new,
);
