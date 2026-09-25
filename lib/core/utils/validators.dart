/// Form field validators. Each returns an error message, or `null` if valid,
/// so they plug directly into `TextFormField.validator`.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9]{9,15}$');

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? fullName(String? value) {
    final error = required(value, field: 'Full name');
    if (error != null) return error;
    if (value!.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? email(String? value) {
    final error = required(value, field: 'Email');
    if (error != null) return error;
    if (!_email.hasMatch(value!.trim())) return 'Enter a valid email address';
    return null;
  }

  /// Login only checks presence; strength rules apply at registration.
  static String? loginPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Password is required' : null;

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use at least 8 characters';
    if (!value.contains(RegExp(r'[A-Za-z]')) || !value.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one letter and one number';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Confirm your password';
      if (value != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? phone(String? value) {
    final error = required(value, field: 'Phone number');
    if (error != null) return error;
    final digits = value!.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phone.hasMatch(digits)) return 'Enter a valid phone number';
    return null;
  }
}
