import 'dart:async';

import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/authentication/domain/entities/app_user.dart';
import 'package:petcare/features/authentication/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] that records calls and can be told to fail.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  Failure? nextFailure;
  bool googleCancels = false;
  final calls = <String>[];

  void _maybeFail() {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
  }

  void _setUser(AppUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    calls.add('signIn:$email');
    _maybeFail();
    _setUser(AppUser(id: 'u1', email: email));
  }

  @override
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    calls.add('register:$email:$fullName:$phone');
    _maybeFail();
    _setUser(AppUser(id: 'u1', email: email, displayName: fullName));
  }

  @override
  Future<bool> signInWithGoogle() async {
    calls.add('google');
    _maybeFail();
    if (googleCancels) return false;
    _setUser(const AppUser(id: 'g1', email: 'g@example.com'));
    return true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    calls.add('reset:$email');
    _maybeFail();
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _setUser(null);
  }

  @override
  bool usesPassword = true;

  @override
  Future<void> reauthenticate({String? password}) async {
    calls.add('reauth:$password');
    _maybeFail();
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    calls.add('changePassword:$currentPassword:$newPassword');
    _maybeFail();
  }

  @override
  Future<void> deleteCurrentUser() async {
    calls.add('deleteUser');
    _maybeFail();
    _setUser(null);
  }
}
