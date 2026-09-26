import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/weight_entry.dart';
import '../providers/weight_providers.dart';

/// UI state (busy / error) for logging and deleting weigh-ins.
class WeightController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> log({
    required String petId,
    required double weightKg,
    required DateTime date,
    String? note,
  }) =>
      _run(() async {
        final uid = ref.read(currentUserIdProvider);
        if (uid == null) throw const Failure('You are signed out. Please sign in again.');
        await ref.read(logWeightProvider)(
          ownerId: uid,
          entry: WeightEntry(ownerId: uid, petId: petId, date: date, weightKg: weightKg, note: note),
        );
      });

  Future<bool> delete(WeightEntry entry) => _run(() => ref.read(deleteWeightEntryProvider)(entry));

  Future<bool> _run(Future<void> Function() action) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await action();
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } catch (error, stack) {
      final failure = error is Failure
          ? error
          : Failure('Something went wrong. Please try again.', cause: error);
      if (ref.mounted) state = AsyncError(failure, stack);
      return false;
    }
  }
}

final weightControllerProvider =
    NotifierProvider.autoDispose<WeightController, AsyncValue<void>>(WeightController.new);
