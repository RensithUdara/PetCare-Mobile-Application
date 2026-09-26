import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Emits the signed-in user, or `null` when signed out.
class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.authStateChanges();
}
