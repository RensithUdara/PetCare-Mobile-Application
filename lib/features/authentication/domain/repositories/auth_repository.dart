import '../entities/app_user.dart';

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

  /// Whether the signed-in user has an email/password login (and so can
  /// change their password in the app). `false` for Google-only accounts.
  bool get usesPassword;

  /// Confirms the user's identity before sensitive changes. Password
  /// accounts must pass [password]; Google accounts re-pick their account.
  Future<void> reauthenticate({String? password});

  Future<void> changePassword({required String currentPassword, required String newPassword});

  /// Permanently deletes the signed-in Firebase user (not their data).
  Future<void> deleteCurrentUser();
}
