import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/auth_error_mapper.dart';
import '../models/user_profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AppUser?> authStateChanges() =>
      _remote.userChanges().map((user) => user?.toEntity());

  @override
  AppUser? get currentUser => _remote.currentUser?.toEntity();

  @override
  Future<void> signInWithEmail({required String email, required String password}) =>
      _guard(() => _remote.signInWithEmail(email, password));

  @override
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) {
    return _guard(() async {
      final credential = await _remote.createUser(email, password);
      final user = credential.user!;
      await _remote.updateDisplayName(user, fullName);
      await _remote.createProfile(
        user.uid,
        UserProfileModel(fullName: fullName, email: email, phone: phone),
      );
    });
  }

  @override
  Future<bool> signInWithGoogle() {
    return _guard(() async {
      final result = await _remote.signInWithGoogle();
      if (result == null) return false;

      final user = result.user!;
      final profile = UserProfileModel(
        fullName: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
      if (result.additionalUserInfo?.isNewUser ?? false) {
        await _remote.createProfile(user.uid, profile);
      } else {
        await _remote.mergeProfile(user.uid, profile.toSignInJson());
      }
      return true;
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => _remote.sendPasswordResetEmail(email));

  @override
  Future<void> signOut() => _guard(_remote.signOut);

  @override
  bool get usesPassword => _remote.providerIds.contains('password');

  @override
  Future<void> reauthenticate({String? password}) => _guard(() async {
        if (usesPassword) {
          if (password == null || password.isEmpty) {
            throw const Failure('Enter your password to continue.', code: 'missing-password');
          }
          await _remote.reauthenticateWithPassword(password);
        } else if (!await _remote.reauthenticateWithGoogle()) {
          throw const Failure('Confirmation cancelled.', code: 'cancelled');
        }
      });

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      _guard(() async {
        await _remote.reauthenticateWithPassword(currentPassword);
        await _remote.updatePassword(newPassword);
      });

  @override
  Future<void> deleteCurrentUser() => _guard(_remote.deleteCurrentUser);

  /// Translates SDK exceptions into domain [Failure]s.
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw Failure(authErrorMessage(e.code), code: e.code, cause: e);
    } on GoogleSignInException catch (e) {
      throw Failure('Google sign-in failed. Please try again.', code: e.code.name, cause: e);
    } on FirebaseException catch (e) {
      throw Failure('Something went wrong. Please try again.', code: e.code, cause: e);
    }
  }
}
