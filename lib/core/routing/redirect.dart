import 'app_routes.dart';

/// Decides where the router should send the user, or `null` to stay put.
///
/// Order of precedence: splash while auth resolves → onboarding on first
/// run → auth screens when signed out → home when signed in.
String? resolveRedirect({
  required String location,
  required bool isAuthLoading,
  required bool onboardingComplete,
  required bool isLoggedIn,
}) {
  if (isAuthLoading) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (!onboardingComplete) {
    return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }

  final onAuthRoute = AppRoutes.authRoutes.contains(location);

  if (!isLoggedIn) {
    return onAuthRoute ? null : AppRoutes.login;
  }

  final onEntryRoute = onAuthRoute ||
      location == AppRoutes.splash ||
      location == AppRoutes.onboarding;
  return onEntryRoute ? AppRoutes.home : null;
}
