/// Holds signup fields across the multi-step registration flow.
class SignUpDraft {
  SignUpDraft._();

  static String email = '';
  static String phone = '';
  static String password = '';
  static String tempPassword = '';
  static String firstName = '';
  static String lastName = '';
  static String role = 'rider';

  static String userId = '';
  static String token = '';
  static String refreshToken = '';

  static bool usedTempPassword = false;
  static bool phoneVerified = false;
  static bool emailVerified = false;

  /// Google OAuth sign-up — skips password and email verification steps.
  static bool isGoogleAuth = false;
  static bool skipPasswordSetup = false;

  /// Placeholder names used for the initial signup call (before personal info).
  static const String placeholderFirstName = 'TravelMate';
  static const String placeholderLastName = 'User';

  static String generateTempPassword() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'Tm!$ts';
  }

  static void reset() {
    email = '';
    phone = '';
    password = '';
    tempPassword = '';
    firstName = '';
    lastName = '';
    role = 'rider';
    userId = '';
    token = '';
    refreshToken = '';
    usedTempPassword = false;
    phoneVerified = false;
    emailVerified = false;
    isGoogleAuth = false;
    skipPasswordSetup = false;
  }
}
