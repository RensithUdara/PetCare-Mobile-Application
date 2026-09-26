import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/firebase_error_handler.dart';
import '../../../../core/sync/pending_write_tracker.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, {PendingWriteTracker? tracker}) : _tracker = tracker;

  final ProfileRemoteDataSource _remote;
  final PendingWriteTracker? _tracker;

  @override
  Stream<UserProfile?> watchProfile(String uid) => guardFirebaseStream(
        _remote.watchProfile(uid).map((s) {
          final data = s.data();
          return data == null ? null : ProfileModel.fromDoc(uid, data);
        }),
        message: 'Could not load your profile.',
      );

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await guardFirebaseWrite(
      () => _remote.mergeProfile(profile.id, ProfileModel.toUpdateJson(profile)),
      label: 'Save profile',
      message: 'Could not save your profile. Please try again.',
      tracker: _tracker,
    );
    try {
      await _remote.updateAuthUser(displayName: profile.fullName, photoUrl: profile.photoUrl);
    } on FirebaseAuthException catch (e) {
      throw Failure('Your details were saved, but your login name couldn’t be updated.',
          code: e.code, cause: e);
    }
  }

  @override
  Future<String> uploadPhoto(String uid, Uint8List bytes) => guardFirebase(
        () => _remote.uploadPhoto(uid, bytes),
        message: 'Could not upload your photo. Please try again.',
      );

  @override
  Future<void> deletePhoto(String photoUrl) => guardFirebase(() => _remote.deletePhoto(photoUrl));

  @override
  Future<void> deleteUserData(String uid) => guardFirebase(
        () => _remote.deleteUserData(uid),
        message: 'Could not delete your data. Please try again.',
      );
}
