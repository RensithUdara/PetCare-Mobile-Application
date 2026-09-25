import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/validators.dart';

void main() {
  test('email', () {
    expect(Validators.email(''), 'Email is required');
    expect(Validators.email('bruno'), 'Enter a valid email address');
    expect(Validators.email('bruno@pets'), 'Enter a valid email address');
    expect(Validators.email(' bruno@pets.lk '), isNull);
  });

  test('fullName', () {
    expect(Validators.fullName('  '), 'Full name is required');
    expect(Validators.fullName('A'), 'Enter your full name');
    expect(Validators.fullName('Kasun Silva'), isNull);
  });

  test('newPassword', () {
    expect(Validators.newPassword(''), 'Password is required');
    expect(Validators.newPassword('abc1'), 'Use at least 8 characters');
    expect(Validators.newPassword('abcdefgh'), 'Include at least one letter and one number');
    expect(Validators.newPassword('12345678'), 'Include at least one letter and one number');
    expect(Validators.newPassword('pawprint1'), isNull);
  });

  test('loginPassword only checks presence', () {
    expect(Validators.loginPassword(''), 'Password is required');
    expect(Validators.loginPassword('x'), isNull);
  });

  test('confirmPassword compares against the original', () {
    final validate = Validators.confirmPassword(() => 'pawprint1');
    expect(validate(''), 'Confirm your password');
    expect(validate('pawprint2'), 'Passwords do not match');
    expect(validate('pawprint1'), isNull);
  });

  test('phone', () {
    expect(Validators.phone(''), 'Phone number is required');
    expect(Validators.phone('123'), 'Enter a valid phone number');
    expect(Validators.phone('abc1234567'), 'Enter a valid phone number');
    expect(Validators.phone('077 123 4567'), isNull);
    expect(Validators.phone('+94771234567'), isNull);
  });

  test('weight is optional but must be a sensible number', () {
    expect(Validators.weight(''), isNull);
    expect(Validators.weight('12.5'), isNull);
    expect(Validators.weight('12,5'), isNull);
    expect(Validators.weight('abc'), 'Enter a number, e.g. 12.5');
    expect(Validators.weight('0'), 'Enter a weight between 0 and 200 kg');
    expect(Validators.weight('250'), 'Enter a weight between 0 and 200 kg');
  });

  test('notInFuture', () {
    final now = DateTime(2026, 9, 26, 9);
    expect(Validators.notInFuture(null, now: now), isNull);
    expect(Validators.notInFuture(DateTime(2026, 9, 26), now: now), isNull);
    expect(Validators.notInFuture(DateTime(2026, 9, 27), now: now),
        'Date cannot be in the future');
  });
}
