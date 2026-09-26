import 'dart:typed_data';

import '../entities/user_profile.dart';

/// Owner profile storage. Implementations throw [Failure].
abstract interface class ProfileRepository {
  /// `null` when the user has no profile document yet.
  Stream<UserProfile?> watchProfile(String uid);

  /// Saves the editable fields and mirrors name/photo onto the login
  /// account so the rest of the app sees them straight away.
  Future<void> saveProfile(UserProfile profile);

  Future<String> uploadPhoto(String uid, Uint8List bytes);

  Future<void> deletePhoto(String photoUrl);

  /// Removes everything stored for the user that isn't attached to a pet
  /// (clinics, vets, devices, profile photo and the profile itself).
  Future<void> deleteUserData(String uid);
}
