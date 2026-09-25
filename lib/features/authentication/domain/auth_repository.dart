import 'app_user.dart';

/// Authentication contract used by the presentation layer.
///
/// Implementations throw [Failure] with a user-presentable message.
abstract interface class AuthRepository {
  /// Emits the current user (including profile updates), or `null` when
  /// signed out.
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<void> signInWithEmail({required String email, required String password});

  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  });

  /// Returns `false` if the user dismissed the Google account picker.
  Future<bool> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
