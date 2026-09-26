import '../repositories/auth_repository.dart';

class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) =>
      _repository.signInWithEmail(email: email.trim(), password: password);
}
