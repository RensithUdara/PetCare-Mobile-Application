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

  // ── Public (no sign-in) ────────────────────────────────────────────────
  /// Emergency profile opened from a scanned QR code / App Link.
  static String publicProfile(String publicId) => '/p/$publicId';
  static bool isPublic(String location) => location.startsWith('/p/');

  // ── Tabs ───────────────────────────────────────────────────────────────
  static const home = '/home';
  static const pets = '/pets';
  static const calendar = '/calendar';
  static const clinics = '/clinics';
  static const profile = '/profile';
  static const notificationSettings = '/profile/notifications';
  static const faq = '/profile/faq';
  static const profileEdit = '/edit/profile';
  static const changePassword = '/edit/password';

  // ── Pets tab ───────────────────────────────────────────────────────────
  static String petDetails(String petId) => '/pets/$petId';
  static String vaccinations(String petId) => '/pets/$petId/vaccinations';
  static String vaccinationDetails(String petId, String id) => '/pets/$petId/vaccinations/$id';
  static String appointments(String petId) => '/pets/$petId/appointments';
  static String appointmentDetails(String petId, String id) => '/pets/$petId/appointments/$id';
  static String medications(String petId) => '/pets/$petId/medications';
  static String medicationDetails(String petId, String id) => '/pets/$petId/medications/$id';
  static String documents(String petId) => '/pets/$petId/documents';
  static String weight(String petId) => '/pets/$petId/weight';
  static String emergency(String petId) => '/pets/$petId/emergency';

  // ── Full-screen viewers ────────────────────────────────────────────────
  static String documentViewer(String id) => '/view/document/$id';

  // ── Home tab ───────────────────────────────────────────────────────────
  static String homeAppointment(String id) => '/home/appointment/$id';
  static String homeVaccination(String id) => '/home/vaccination/$id';
  static String homeMedication(String id) => '/home/medication/$id';

  // ── Clinics tab ────────────────────────────────────────────────────────
  static const clinicsMap = '/clinics/map';
  static String clinicDetails(String id) => '/clinics/$id';

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

  static const clinicNew = '/edit/clinic';
  static String clinicEdit(String id) => '/edit/clinic/$id';
  static String vetNew({String? clinicId}) =>
      clinicId == null ? '/edit/vet' : '/edit/vet?clinicId=$clinicId';
  static String vetEdit(String id) => '/edit/vet/$id';
}
