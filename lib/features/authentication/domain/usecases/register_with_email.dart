import '../repositories/auth_repository.dart';

/// Creates the account and the user's profile document.
class RegisterWithEmail {
  const RegisterWithEmail(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) =>
      _repository.registerWithEmail(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        phone: phone.trim(),
      );
}
