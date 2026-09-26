import '../utils/date_utils.dart';

/// Route paths. Forms live under `/edit/...` outside the tab shell so any
/// tab can open them full-screen; details pages live inside their tab.
abstract final class AppRoutes {
  // ── Entry ──────────────────────────────────────────────────────────────
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const authRoutes = {login, register, forgotPassword};

  // ── Tabs ───────────────────────────────────────────────────────────────
  static const home = '/home';
  static const pets = '/pets';
  static const calendar = '/calendar';
  static const clinics = '/clinics';
  static const profile = '/profile';
  static const notificationSettings = '/profile/notifications';

  // ── Pets tab ───────────────────────────────────────────────────────────
  static String petDetails(String petId) => '/pets/$petId';
  static String vaccinations(String petId) => '/pets/$petId/vaccinations';
  static String vaccinationDetails(String petId, String id) => '/pets/$petId/vaccinations/$id';
  static String appointments(String petId) => '/pets/$petId/appointments';
  static String appointmentDetails(String petId, String id) => '/pets/$petId/appointments/$id';
  static String medications(String petId) => '/pets/$petId/medications';
  static String medicationDetails(String petId, String id) => '/pets/$petId/medications/$id';
  static String documents(String petId) => '/pets/$petId/documents';

  // ── Full-screen viewers ────────────────────────────────────────────────
  static String documentViewer(String id) => '/view/document/$id';

  // ── Home tab ───────────────────────────────────────────────────────────
  static String homeAppointment(String id) => '/home/appointment/$id';
  static String homeVaccination(String id) => '/home/vaccination/$id';
  static String homeMedication(String id) => '/home/medication/$id';

  // ── Calendar tab ───────────────────────────────────────────────────────
  static String calendarAppointment(String id) => '/calendar/appointment/$id';
  static String calendarVaccination(String id) => '/calendar/vaccination/$id';
  static String calendarMedication(String id) => '/calendar/medication/$id';

  // ── Forms (full-screen) ────────────────────────────────────────────────
  static const petNew = '/edit/pet';
  static String petEdit(String petId) => '/edit/pet/$petId';

  static String vaccinationNew(String petId) => '/edit/vaccination?petId=$petId';
  static String vaccinationEdit(String id) => '/edit/vaccination/$id';

  static String appointmentNew({String? petId, DateTime? date}) {
    final query = [
      if (petId != null) 'petId=$petId',
      if (date != null) 'date=${dateOnly(date).toIso8601String().substring(0, 10)}',
    ].join('&');
    return query.isEmpty ? '/edit/appointment' : '/edit/appointment?$query';
  }

  static String appointmentEdit(String id) => '/edit/appointment/$id';

  static String medicationNew(String petId) => '/edit/medication?petId=$petId';
  static String medicationEdit(String id) => '/edit/medication/$id';

  /// [type] is a `DocumentType` name (core must not import feature types).
  static String documentNew({
    required String petId,
    String? vaccinationId,
    String? type,
    String? name,
  }) =>
      Uri(path: '/edit/document', queryParameters: {
        'petId': petId,
        'vaccinationId': ?vaccinationId,
        'type': ?type,
        'name': ?name,
      }).toString();
  static String documentEdit(String id) => '/edit/document/$id';
}
