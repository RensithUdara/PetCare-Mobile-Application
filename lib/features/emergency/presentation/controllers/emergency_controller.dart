import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../pets/domain/entities/pet.dart';
import '../../domain/entities/emergency_profile.dart';
import '../providers/emergency_providers.dart';

/// UI state (busy / error) for the owner's emergency profile screen.
class EmergencyController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(Pet pet, {required String contactPhone, String? contactName}) => _run(() async {
        final uid = ref.read(currentUserIdProvider);
        if (uid == null) throw const Failure('You are signed out. Please sign in again.');
        await ref.read(createEmergencyProfileProvider)(
          ownerId: uid,
          pet: pet,
          contactPhone: contactPhone,
          contactName: contactName,
        );
      });

  Future<bool> save(Pet pet, EmergencyProfile settings) =>
      _run(() => ref.read(saveEmergencyProfileProvider)(pet: pet, settings: settings));

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

final emergencyControllerProvider =
    NotifierProvider.autoDispose<EmergencyController, AsyncValue<void>>(EmergencyController.new);
