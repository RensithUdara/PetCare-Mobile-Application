import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/authentication/data/mappers/auth_error_mapper.dart';

void main() {
  test('credential errors share one message to avoid account enumeration', () {
    const expected = 'Incorrect email or password.';
    for (final code in ['user-not-found', 'wrong-password', 'invalid-credential']) {
      expect(authErrorMessage(code), expected, reason: code);
    }
  });

  test('maps specific codes', () {
    expect(authErrorMessage('email-already-in-use'),
        'An account already exists with this email.');
    expect(authErrorMessage('network-request-failed'), contains('internet'));
  });

  test('falls back to a generic message', () {
    expect(authErrorMessage('something-new'), 'Something went wrong. Please try again.');
  });
}
