import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
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

  /// Returns the pet id on success, `null` on failure.
  Future<String?> save(Pet pet, {PhotoChange photo = const PhotoUnchanged()}) async {
    if (state.isBusy) return null;
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
      if (ref.mounted) state = const PetEditorState();
      return id;
    } catch (e) {
      _fail(e);
      return null;
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
