import '../../../../core/errors/failure.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';

class ChangePassword {
  const ChangePassword(this._auth);

  final AuthRepository _auth;

  Future<void> call({required String currentPassword, required String newPassword}) {
    if (newPassword == currentPassword) {
      throw const Failure('Choose a password different from your current one.', code: 'same-password');
    }
    return _auth.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }
}
