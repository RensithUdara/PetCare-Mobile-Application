import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/routing/app_routes.dart';
import 'package:petcare/core/routing/redirect.dart';

void main() {
  String? redirect(
    String location, {
    bool loading = false,
    bool onboarded = true,
    bool loggedIn = false,
  }) =>
      resolveRedirect(
        location: location,
        isAuthLoading: loading,
        onboardingComplete: onboarded,
        isLoggedIn: loggedIn,
      );

  group('resolveRedirect', () {
    test('shows splash while auth is loading', () {
      expect(redirect(AppRoutes.home, loading: true), AppRoutes.splash);
      expect(redirect(AppRoutes.splash, loading: true), isNull);
    });

    test('forces onboarding on first run', () {
      expect(redirect(AppRoutes.splash, onboarded: false), AppRoutes.onboarding);
      expect(redirect(AppRoutes.login, onboarded: false), AppRoutes.onboarding);
      expect(redirect(AppRoutes.onboarding, onboarded: false), isNull);
    });

    test('sends signed-out users to login but allows auth routes', () {
      expect(redirect(AppRoutes.splash), AppRoutes.login);
      expect(redirect(AppRoutes.home), AppRoutes.login);
      expect(redirect(AppRoutes.login), isNull);
      expect(redirect(AppRoutes.register), isNull);
      expect(redirect(AppRoutes.forgotPassword), isNull);
    });

    test('sends signed-in users from entry routes to home', () {
      for (final route in [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
      ]) {
        expect(redirect(route, loggedIn: true), AppRoutes.home, reason: route);
      }
    });

    test('leaves signed-in users on app routes', () {
      expect(redirect(AppRoutes.home, loggedIn: true), isNull);
      expect(redirect(AppRoutes.pets, loggedIn: true), isNull);
    });
  });
}
