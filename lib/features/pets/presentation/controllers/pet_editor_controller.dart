import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/clock.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../emergency/presentation/providers/emergency_providers.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../../weight/domain/entities/weight_entry.dart';
import '../../../weight/presentation/providers/weight_providers.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/photo_change.dart';
import '../providers/pet_providers.dart';

@immutable
class PetEditorState {
  const PetEditorState({this.isBusy = false, this.uploadProgress, this.error});

  final bool isBusy;

  /// 0–1 while a photo is uploading, otherwise `null`.
  final double? uploadProgress;
  final Failure? error;
}

/// UI state for saving / deleting a pet. Business rules live in the
/// [SavePet] and [DeletePet] use cases.
class PetEditorController extends Notifier<PetEditorState> {
  @override
  PetEditorState build() => const PetEditorState();

  String _requireUid() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) throw const Failure('You are signed out. Please sign in again.');
    return uid;
  }

  /// Returns the pet id on success, `null` on failure. With [logWeight],
  /// the pet's weight is also recorded as today's weigh-in.
  Future<String?> save(
    Pet pet, {
    PhotoChange photo = const PhotoUnchanged(),
    bool logWeight = false,
  }) async {
    if (state.isBusy) return null;
    if (photo is PhotoReplaced && ref.read(isOfflineProvider)) {
      state = const PetEditorState(
        error: Failure(
          'You’re offline. Uploading photos and documents needs an internet connection — '
          'try again when you’re back online.',
          code: 'offline',
        ),
      );
      return null;
    }
    state = const PetEditorState(isBusy: true);
    try {
      final id = await ref.read(savePetProvider)(
        ownerId: _requireUid(),
        pet: pet,
        photo: photo,
        onUploadProgress: (p) {
          if (ref.mounted) state = PetEditorState(isBusy: true, uploadProgress: p);
        },
      );
      if (logWeight && pet.weightKg != null) await _logWeight(id, pet.weightKg!);
      if (!pet.isNew) await _refreshPublicProfile(id);
      if (ref.mounted) state = const PetEditorState();
      return id;
    } catch (e) {
      _fail(e);
      return null;
    }
  }

  /// Keeps the weight history in step with the weight entered in the pet
  /// form. Best effort: the pet itself is already saved.
  Future<void> _logWeight(String petId, double weightKg) async {
    try {
      final uid = _requireUid();
      await ref.read(logWeightProvider)(
        ownerId: uid,
        entry: WeightEntry(
          ownerId: uid,
          petId: petId,
          date: ref.read(clockProvider)(),
          weightKg: weightKg,
        ),
      );
    } catch (e) {
      debugPrint('Could not log weight: $e');
    }
  }

  /// Name/photo/breed changes must reach the public QR page. Best effort.
  Future<void> _refreshPublicProfile(String petId) async {
    try {
      final uid = _requireUid();
      final pet = await ref.read(petRepositoryProvider).watchPet(uid, petId).first;
      if (pet != null) await ref.read(refreshPublicProfileProvider)(ownerId: uid, pet: pet);
    } catch (e) {
      debugPrint('Could not refresh public profile: $e');
    }
  }

  Future<bool> delete(String petId) async {
    if (state.isBusy) return false;
    state = const PetEditorState(isBusy: true);
    try {
      await ref.read(deletePetProvider)(ownerId: _requireUid(), petId: petId);
      if (ref.mounted) state = const PetEditorState();
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  void _fail(Object error) {
    final failure = error is Failure
        ? error
        : Failure('Something went wrong. Please try again.', cause: error);
    if (ref.mounted) state = PetEditorState(error: failure);
  }
}

final petEditorControllerProvider =
    NotifierProvider.autoDispose<PetEditorController, PetEditorState>(
  PetEditorController.new,
);
