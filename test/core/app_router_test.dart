import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/routing/app_router.dart';
import 'package:petcare/core/routing/app_routes.dart';
import 'package:petcare/features/authentication/presentation/providers/auth_providers.dart';
import 'package:petcare/features/onboarding/presentation/providers/onboarding_controller.dart';

import '../helpers/fake_auth_repository.dart';

/// Every path produced by [AppRoutes] must match a registered route.
void main() {
  test('all AppRoutes resolve', () {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      onboardingCompleteProvider.overrideWithBuild((_, _) => true),
    ]);
    addTearDown(container.dispose);
    final config = container.read(appRouterProvider).configuration;

    final paths = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.home,
      AppRoutes.pets,
      AppRoutes.calendar,
      AppRoutes.clinics,
      AppRoutes.profile,
      AppRoutes.petDetails('p1'),
      AppRoutes.vaccinations('p1'),
      AppRoutes.vaccinationDetails('p1', 'v1'),
      AppRoutes.appointments('p1'),
      AppRoutes.appointmentDetails('p1', 'a1'),
      AppRoutes.calendarAppointment('a1'),
      AppRoutes.calendarVaccination('v1'),
      AppRoutes.petNew,
      AppRoutes.petEdit('p1'),
      AppRoutes.vaccinationNew('p1'),
      AppRoutes.vaccinationEdit('v1'),
      AppRoutes.appointmentNew(petId: 'p1', date: DateTime(2026, 10, 1)),
      AppRoutes.appointmentEdit('a1'),
    ];

    for (final path in paths) {
      final match = config.findMatch(Uri.parse(path));
      expect(match.isError, isFalse, reason: path);
      expect(match.uri.path, Uri.parse(path).path, reason: path);
    }
  });
}
