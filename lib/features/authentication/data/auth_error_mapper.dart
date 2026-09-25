/// Translates Firebase Auth error codes into user-friendly messages.
String authErrorMessage(String code) {
  return switch (code) {
    'invalid-email' => 'That email address is not valid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' ||
    'INVALID_LOGIN_CREDENTIALS' =>
      'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists with this email.',
    'weak-password' => 'Please choose a stronger password.',
    'account-exists-with-different-credential' =>
      'An account already exists with this email using a different sign-in method.',
    'too-many-requests' => 'Too many attempts. Please wait a moment and try again.',
    'network-request-failed' => 'No internet connection. Check your network and try again.',
    'requires-recent-login' => 'Please sign in again to continue.',
    'operation-not-allowed' => 'This sign-in method is not enabled.',
    _ => 'Something went wrong. Please try again.',
  };
}
