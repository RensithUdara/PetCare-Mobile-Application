import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/clinic.dart';
import '../providers/clinic_providers.dart';

/// UI state (busy / error) for clinic and veterinarian actions.
class ClinicEditorController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> saveClinic(Clinic clinic) =>
      _run(() => ref.read(saveClinicProvider)(ownerId: _uid(), clinic: clinic));

  Future<bool> toggleFavorite(Clinic clinic) async =>
      await _run(() async {
        await ref.read(toggleFavoriteClinicProvider)(clinic);
        return clinic.id;
      }) !=
      null;

  Future<bool> deleteClinic(String clinicId) async =>
      await _run(() async {
        await ref.read(deleteClinicProvider)(ownerId: _uid(), clinicId: clinicId);
        return clinicId;
      }) !=
      null;

  Future<String?> saveVet(Veterinarian vet) =>
      _run(() => ref.read(saveVetProvider)(ownerId: _uid(), vet: vet));

  Future<bool> deleteVet(String vetId) async =>
      await _run(() async {
        await ref.read(deleteVetProvider)(ownerId: _uid(), vetId: vetId);
        return vetId;
      }) !=
      null;

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

final clinicEditorControllerProvider =
    NotifierProvider.autoDispose<ClinicEditorController, AsyncValue<void>>(
  ClinicEditorController.new,
);
