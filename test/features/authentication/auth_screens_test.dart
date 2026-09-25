import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/errors/failure.dart';
import 'package:petcare/features/authentication/presentation/auth_providers.dart';
import 'package:petcare/features/authentication/presentation/forgot_password_screen.dart';
import 'package:petcare/features/authentication/presentation/login_screen.dart';
import 'package:petcare/features/authentication/presentation/register_screen.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(home: screen),
      ),
    );
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  group('LoginScreen', () {
    testWidgets('shows validation errors and does not submit', (tester) async {
      await pump(tester, const LoginScreen());
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('submits valid credentials', (tester) async {
      await pump(tester, const LoginScreen());
      await tester.enterText(field('Email'), 'bruno@pets.lk');
      await tester.enterText(field('Password'), 'secret');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(repo.calls, ['signIn:bruno@pets.lk']);
    });

    testWidgets('shows a SnackBar when sign-in fails', (tester) async {
      repo.nextFailure = const Failure('Incorrect email or password.');
      await pump(tester, const LoginScreen());
      await tester.enterText(field('Email'), 'bruno@pets.lk');
      await tester.enterText(field('Password'), 'wrong');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('password visibility toggles', (tester) async {
      await pump(tester, const LoginScreen());
      EditableText editable() => tester.widget<EditableText>(find.descendant(
          of: field('Password'), matching: find.byType(EditableText)));

      expect(editable().obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(editable().obscureText, isFalse);
    });
  });

  group('RegisterScreen', () {
    Future<void> fill(WidgetTester tester, {required String confirm}) async {
      await tester.enterText(field('Full name'), 'Kasun Silva');
      await tester.enterText(field('Email'), 'k@pets.lk');
      await tester.enterText(field('Phone number'), '0771234567');
      await tester.enterText(field('Password'), 'pawprint1');
      await tester.enterText(field('Confirm password'), confirm);
      await tester.tap(find.text('Create Account'));
      await tester.pump();
    }

    testWidgets('rejects mismatched passwords', (tester) async {
      await pump(tester, const RegisterScreen());
      await fill(tester, confirm: 'pawprint2');

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('registers with valid input', (tester) async {
      await pump(tester, const RegisterScreen());
      await fill(tester, confirm: 'pawprint1');

      expect(repo.calls, ['register:k@pets.lk:Kasun Silva:0771234567']);
    });
  });

  testWidgets('ForgotPasswordScreen shows confirmation after sending', (tester) async {
    await pump(tester, const ForgotPasswordScreen());
    await tester.enterText(field('Email'), 'bruno@pets.lk');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['reset:bruno@pets.lk']);
    expect(find.text('Check your email'), findsOneWidget);
  });
}
