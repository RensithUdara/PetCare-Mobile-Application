import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  /// Returns `false` if the user dismissed the account picker.
  Future<bool> call() => _repository.signInWithGoogle();
}
