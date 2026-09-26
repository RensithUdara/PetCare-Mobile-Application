import 'dart:async';
import 'dart:typed_data';

import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/profile/domain/entities/user_profile.dart';
import 'package:petcare/features/profile/domain/repositories/profile_repository.dart';

/// In-memory [ProfileRepository] that records calls.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository([this._profile]);

  UserProfile? _profile;
  final _changes = StreamController<void>.broadcast();
  final calls = <String>[];
  Failure? saveFailure;

  UserProfile? get profile => _profile;

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    yield _profile;
    yield* _changes.stream.map((_) => _profile);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    calls.add('save:${profile.fullName}');
    if (saveFailure != null) throw saveFailure!;
    _profile = profile;
    _changes.add(null);
  }

  @override
  Future<String> uploadPhoto(String uid, Uint8List bytes) async {
    calls.add('upload:${bytes.length}');
    return 'https://photos/new.jpg';
  }

  @override
  Future<void> deletePhoto(String photoUrl) async => calls.add('deletePhoto:$photoUrl');

  @override
  Future<void> deleteUserData(String uid) async {
    calls.add('deleteUserData:$uid');
    _profile = null;
    _changes.add(null);
  }
}
