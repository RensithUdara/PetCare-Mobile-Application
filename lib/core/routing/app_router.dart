import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/auth_providers.dart';
import '../../features/authentication/presentation/forgot_password_screen.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/register_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/clinics/presentation/clinics_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/data/onboarding_controller.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/pets/presentation/pet_details_screen.dart';
import '../../features/pets/presentation/pet_form_screen.dart';
import '../../features/pets/presentation/pets_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'app_routes.dart';
import 'main_shell.dart';
import 'redirect.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever auth or onboarding state changes, without
  // rebuilding the router itself.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.listen(onboardingCompleteProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      return resolveRedirect(
        location: state.matchedLocation,
        isAuthLoading: !auth.hasValue && !auth.hasError,
        onboardingComplete: ref.read(onboardingCompleteProvider),
        isLoggedIn: auth.value != null,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          _branch(AppRoutes.home, const HomeScreen()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.pets,
                builder: (context, state) => const PetsScreen(),
                routes: [
                  // Forms cover the bottom navigation (root navigator).
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const PetFormScreen(),
                  ),
                  GoRoute(
                    path: ':petId',
                    builder: (context, state) =>
                        PetDetailsScreen(petId: state.pathParameters['petId']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) =>
                            PetFormScreen(petId: state.pathParameters['petId']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          _branch(AppRoutes.calendar, const CalendarScreen()),
          _branch(AppRoutes.clinics, const ClinicsScreen()),
          _branch(AppRoutes.profile, const ProfileScreen()),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => screen)],
    );
