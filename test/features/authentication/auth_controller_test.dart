import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/authentication/presentation/auth_controller.dart';
import 'package:petcare/features/authentication/presentation/auth_providers.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    // Keep the auto-dispose provider alive for the duration of the test.
    container.listen(authControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  AuthController controller() => container.read(authControllerProvider.notifier);

  test('successful sign-in ends in data state', () async {
    expect(await controller().signIn('a@b.co', 'pw'), isTrue);
    expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    expect(repo.calls, ['signIn:a@b.co']);
  });

  test('failure is exposed as AsyncError carrying the Failure', () async {
    repo.nextFailure = const Failure('Incorrect email or password.');
    expect(await controller().signIn('a@b.co', 'bad'), isFalse);

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect((state.error! as Failure).message, 'Incorrect email or password.');
  });

  test('cancelled Google sign-in is not treated as an error', () async {
    repo.googleCancels = true;
    expect(await controller().signInWithGoogle(), isFalse);
    expect(container.read(authControllerProvider).hasError, isFalse);
  });

  test('register forwards all fields', () async {
    await controller().register(
      fullName: 'Kasun Silva',
      email: 'k@pets.lk',
      password: 'pawprint1',
      phone: '0771234567',
    );
    expect(repo.calls, ['register:k@pets.lk:Kasun Silva:0771234567']);
  });
}
