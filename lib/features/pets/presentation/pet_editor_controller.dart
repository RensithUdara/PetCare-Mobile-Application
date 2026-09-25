import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../authentication/presentation/auth_providers.dart';
import '../domain/pet.dart';
import 'pet_providers.dart';

/// What the user did to the photo while editing.
sealed class PhotoChange {
  const PhotoChange();
}

class PhotoUnchanged extends PhotoChange {
  const PhotoUnchanged();
}

class PhotoReplaced extends PhotoChange {
  const PhotoReplaced(this.bytes);
  final Uint8List bytes;
}

class PhotoRemoved extends PhotoChange {
  const PhotoRemoved();
}

@immutable
class PetEditorState {
  const PetEditorState({this.isBusy = false, this.uploadProgress, this.error});

  final bool isBusy;

  /// 0–1 while a photo is uploading, otherwise `null`.
  final double? uploadProgress;
  final Failure? error;
}

class PetEditorController extends Notifier<PetEditorState> {
  @override
  PetEditorState build() => const PetEditorState();

  String _requireUid() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) throw const Failure('You are signed out. Please sign in again.');
    return uid;
  }

  /// Creates or updates [pet] (an empty [Pet.id] means new) and applies
  /// [photo]. Returns the pet id on success, `null` on failure.
  Future<String?> save(Pet pet, {PhotoChange photo = const PhotoUnchanged()}) async {
    if (state.isBusy) return null;
    state = const PetEditorState(isBusy: true);

    try {
      final repo = ref.read(petRepositoryProvider);
      final uid = _requireUid();
      final id = pet.id.isEmpty ? repo.newPetId(uid) : pet.id;
      final oldPhotoUrl = pet.photoUrl;
      var photoUrl = oldPhotoUrl;

      switch (photo) {
        case PhotoReplaced(:final bytes):
          photoUrl = await repo.uploadPhoto(
            ownerId: uid,
            petId: id,
            bytes: bytes,
            onProgress: (p) {
              if (ref.mounted) state = PetEditorState(isBusy: true, uploadProgress: p);
            },
          );
        case PhotoRemoved():
          photoUrl = null;
        case PhotoUnchanged():
          break;
      }

      await repo.savePet(pet.copyWith(id: id, ownerId: uid, photoUrl: photoUrl));

      // Clean up the old file only after the pet points at the new one.
      if (oldPhotoUrl != null && oldPhotoUrl != photoUrl) {
        try {
          await repo.deletePhoto(oldPhotoUrl);
        } catch (_) {
          // An orphaned file is harmless; don't fail the save.
        }
      }

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
      await ref.read(petRepositoryProvider).deletePet(_requireUid(), petId);
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
