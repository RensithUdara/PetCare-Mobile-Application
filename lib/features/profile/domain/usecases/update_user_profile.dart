import '../../../../core/errors/failure.dart';
import '../../../pets/domain/entities/photo_change.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Saves profile edits, uploading / removing the photo as needed.
class UpdateUserProfile {
  const UpdateUserProfile(this._repository);

  final ProfileRepository _repository;

  Future<void> call(UserProfile profile, {PhotoChange photo = const PhotoUnchanged()}) async {
    final name = profile.fullName.trim();
    if (name.length < 2) throw const Failure('Please enter your full name.', code: 'invalid-name');

    String? trimOrNull(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final oldPhoto = profile.photoUrl;

    final photoUrl = switch (photo) {
      PhotoReplaced(:final bytes) => await _repository.uploadPhoto(profile.id, bytes),
      PhotoRemoved() => null,
      PhotoUnchanged() => oldPhoto,
    };

    await _repository.saveProfile(profile.copyWith(
      fullName: name,
      phone: () => trimOrNull(profile.phone),
      city: () => trimOrNull(profile.city),
      photoUrl: () => photoUrl,
    ));

    // Old file last, so a failed save never leaves the profile without one.
    if (oldPhoto != null && oldPhoto != photoUrl) {
      try {
        await _repository.deletePhoto(oldPhoto);
      } on Failure {
        // Orphaned file only; the profile itself is saved.
      }
    }
  }
}
