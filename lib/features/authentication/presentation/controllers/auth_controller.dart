import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../providers/auth_providers.dart';

/// Drives the auth screens: exposes loading / error state for the
/// in-flight action. Navigation after sign-in is handled by the router.
///
/// Auto-disposed so each screen starts with a clean state.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> signIn(String email, String password) =>
      _run(() => ref.read(signInWithEmailProvider)(email: email, password: password));

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) =>
      _run(
        () => ref.read(registerWithEmailProvider)(
          fullName: fullName,
          email: email,
          password: password,
          phone: phone,
        ),
      );

  Future<bool> signInWithGoogle() async {
    var completed = false;
    await _run(() async => completed = await ref.read(signInWithGoogleProvider)());
    return completed;
  }

  Future<bool> sendPasswordReset(String email) =>
      _run(() => ref.read(sendPasswordResetEmailProvider)(email));

  /// Returns `true` on success.
  Future<bool> _run(Future<void> Function() action) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await action();
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } catch (error, stack) {
      final failure = error is Failure
          ? error
          : Failure('Something went wrong. Please try again.', cause: error);
      if (ref.mounted) state = AsyncError(failure, stack);
      return false;
    }
  }
}

final authControllerProvider =
    NotifierProvider.autoDispose<AuthController, AsyncValue<void>>(
  AuthController.new,
);
