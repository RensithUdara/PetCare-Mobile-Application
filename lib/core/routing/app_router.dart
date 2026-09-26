import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/screens/appointment_details_screen.dart';
import '../../features/appointments/presentation/screens/appointment_form_screen.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/clinics/presentation/screens/clinic_details_screen.dart';
import '../../features/clinics/presentation/screens/clinic_form_screen.dart';
import '../../features/clinics/presentation/screens/clinics_map_screen.dart';
import '../../features/clinics/presentation/screens/clinics_screen.dart';
import '../../features/clinics/presentation/screens/vet_form_screen.dart';
import '../../features/documents/domain/entities/medical_document.dart';
import '../../features/documents/presentation/screens/document_form_screen.dart';
import '../../features/documents/presentation/screens/document_viewer_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/emergency/presentation/screens/emergency_profile_screen.dart';
import '../../features/emergency/presentation/screens/public_profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/medications/presentation/screens/medication_details_screen.dart';
import '../../features/medications/presentation/screens/medication_form_screen.dart';
import '../../features/medications/presentation/screens/medications_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_controller.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/pets/presentation/screens/pet_details_screen.dart';
import '../../features/pets/presentation/screens/pet_form_screen.dart';
import '../../features/pets/presentation/screens/pets_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/vaccinations/presentation/screens/vaccination_details_screen.dart';
import '../../features/weight/presentation/screens/weight_screen.dart';
import '../../features/vaccinations/presentation/screens/vaccination_form_screen.dart';
import '../../features/vaccinations/presentation/screens/vaccinations_screen.dart';
import 'app_routes.dart';
import 'main_shell.dart';
import 'redirect.dart';
import 'splash_timer.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever auth or onboarding state changes, without
  // rebuilding the router itself.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.listen(onboardingCompleteProvider, (_, _) => refresh.value++);
  ref.listen(splashTimerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      return resolveRedirect(
        location: state.matchedLocation,
        isAuthLoading: (!auth.hasValue && !auth.hasError) || !ref.read(splashTimerProvider).hasValue,
        onboardingComplete: ref.read(onboardingCompleteProvider),
        isLoggedIn: auth.value != null,
      );
    },
    routes: [
      _route(AppRoutes.splash, (_) => const SplashScreen()),
      _route(AppRoutes.onboarding, (_) => const OnboardingScreen()),
      _route(AppRoutes.login, (_) => const LoginScreen()),
      _route(AppRoutes.register, (_) => const RegisterScreen()),
      _route(AppRoutes.forgotPassword, (_) => const ForgotPasswordScreen()),
      _route('/p/:publicId', (s) => PublicProfileScreen(publicId: s.param('publicId'))),
      ..._formRoutes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          _branch(_homeRoute),
          _branch(_petsRoute),
          _branch(_calendarRoute),
          _branch(_route(
            AppRoutes.clinics,
            (_) => const ClinicsScreen(),
            routes: [
              // 'map' must precede ':id'.
              _route('map', (_) => const ClinicsMapScreen()),
              _route(':id', (s) => ClinicDetailsScreen(clinicId: s.param('id'))),
            ],
          )),
          _branch(_route(
            AppRoutes.profile,
            (_) => const ProfileScreen(),
            routes: [_route('notifications', (_) => const NotificationSettingsScreen())],
          )),
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

GoRoute _route(
  String path,
  Widget Function(GoRouterState state) build, {
  List<RouteBase> routes = const [],
}) =>
    GoRoute(path: path, builder: (context, state) => build(state), routes: routes);

StatefulShellBranch _branch(GoRoute root) => StatefulShellBranch(routes: [root]);

extension on GoRouterState {
  String param(String name) => pathParameters[name]!;
  String? query(String name) => uri.queryParameters[name];
}

/// `/pets`, `/pets/:petId`, `/pets/:petId/{vaccinations,appointments,medications}/...`
final _petsRoute = _route(
  AppRoutes.pets,
  (_) => const PetsScreen(),
  routes: [
    _route(
      ':petId',
      (s) => PetDetailsScreen(petId: s.param('petId')),
      routes: [
        _route(
          'vaccinations',
          (s) => VaccinationsScreen(petId: s.param('petId')),
          routes: [
            _route(':id', (s) => VaccinationDetailsScreen(vaccinationId: s.param('id'))),
          ],
        ),
        _route(
          'appointments',
          (s) => AppointmentsScreen(petId: s.param('petId')),
          routes: [
            _route(':id', (s) => AppointmentDetailsScreen(appointmentId: s.param('id'))),
          ],
        ),
        _route('documents', (s) => DocumentsScreen(petId: s.param('petId'))),
        _route('weight', (s) => WeightScreen(petId: s.param('petId'))),
        _route('emergency', (s) => EmergencyProfileScreen(petId: s.param('petId'))),
        _route(
          'medications',
          (s) => MedicationsScreen(petId: s.param('petId')),
          routes: [
            _route(':id', (s) => MedicationDetailsScreen(medicationId: s.param('id'))),
          ],
        ),
      ],
    ),
  ],
);

/// `/home`, `/home/{appointment,vaccination,medication}/:id`
final _homeRoute = _route(
  AppRoutes.home,
  (_) => const HomeScreen(),
  routes: _recordDetailRoutes,
);

/// Details of any health record, opened from within a tab.
final _recordDetailRoutes = [
  _route('appointment/:id', (s) => AppointmentDetailsScreen(appointmentId: s.param('id'))),
  _route('vaccination/:id', (s) => VaccinationDetailsScreen(vaccinationId: s.param('id'))),
  _route('medication/:id', (s) => MedicationDetailsScreen(medicationId: s.param('id'))),
];

/// `/calendar`, `/calendar/{appointment,vaccination,medication}/:id`
final _calendarRoute = _route(
  AppRoutes.calendar,
  (_) => const CalendarScreen(),
  routes: _recordDetailRoutes,
);

/// Full-screen forms and viewers, reachable from any tab.
final _formRoutes = [
  _route(AppRoutes.petNew, (_) => const PetFormScreen()),
  _route('/edit/pet/:petId', (s) => PetFormScreen(petId: s.param('petId'))),
  _route('/edit/vaccination', (s) => VaccinationFormScreen(petId: s.query('petId'))),
  _route('/edit/vaccination/:id', (s) => VaccinationFormScreen(vaccinationId: s.param('id'))),
  _route(
    '/edit/appointment',
    (s) => AppointmentFormScreen(
      petId: s.query('petId'),
      initialDate: DateTime.tryParse(s.query('date') ?? ''),
    ),
  ),
  _route('/edit/appointment/:id', (s) => AppointmentFormScreen(appointmentId: s.param('id'))),
  _route('/edit/medication', (s) => MedicationFormScreen(petId: s.query('petId'))),
  _route('/edit/medication/:id', (s) => MedicationFormScreen(medicationId: s.param('id'))),
  _route(
    '/edit/document',
    (s) => DocumentFormScreen(
      petId: s.query('petId'),
      vaccinationId: s.query('vaccinationId'),
      initialType: DocumentType.values.asNameMap()[s.query('type')],
      initialName: s.query('name'),
    ),
  ),
  _route('/edit/document/:id', (s) => DocumentFormScreen(documentId: s.param('id'))),
  _route('/view/document/:id', (s) => DocumentViewerScreen(documentId: s.param('id'))),
  _route(AppRoutes.clinicNew, (_) => const ClinicFormScreen()),
  _route('/edit/clinic/:id', (s) => ClinicFormScreen(clinicId: s.param('id'))),
  _route('/edit/vet', (s) => VetFormScreen(clinicId: s.query('clinicId'))),
  _route('/edit/vet/:id', (s) => VetFormScreen(vetId: s.param('id'))),
];
