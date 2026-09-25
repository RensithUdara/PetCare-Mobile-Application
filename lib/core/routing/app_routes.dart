abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const pets = '/pets';
  static const petAdd = '/pets/add';
  static String petDetails(String petId) => '/pets/$petId';
  static String petEdit(String petId) => '/pets/$petId/edit';
  static const calendar = '/calendar';
  static const clinics = '/clinics';
  static const profile = '/profile';

  static const authRoutes = {login, register, forgotPassword};
}
