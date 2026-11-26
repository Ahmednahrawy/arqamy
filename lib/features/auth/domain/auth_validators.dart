enum AuthValidationError {
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordTooShort,
  confirmPasswordRequired,
  passwordsDoNotMatch,
}

/// Input checks for the auth forms. Each method returns null when the input
/// is valid. The UI maps the returned error to a localized message.
class AuthValidators {
  const AuthValidators._();

  static const int minPasswordLength = 8;
  static const int maxEmailLength = 254;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// The form that is sent to the backend: trimmed and lower-case.
  static String normalizeEmail(String? email) =>
      (email ?? '').trim().toLowerCase();

  static AuthValidationError? validateEmail(String? email) {
    final value = (email ?? '').trim();
    if (value.isEmpty) return AuthValidationError.emailRequired;
    if (value.length > maxEmailLength || !_emailPattern.hasMatch(value)) {
      return AuthValidationError.emailInvalid;
    }
    return null;
  }

  /// Sign-in only requires a value. The length rule applies to new passwords,
  /// so an account made under an older rule can still sign in.
  static AuthValidationError? validateLoginPassword(String? password) {
    if (password == null || password.isEmpty) {
      return AuthValidationError.passwordRequired;
    }
    return null;
  }

  static AuthValidationError? validateNewPassword(String? password) {
    if (password == null || password.isEmpty) {
      return AuthValidationError.passwordRequired;
    }
    if (password.length < minPasswordLength) {
      return AuthValidationError.passwordTooShort;
    }
    return null;
  }

  static AuthValidationError? validateConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return AuthValidationError.confirmPasswordRequired;
    }
    if (password != confirmation) {
      return AuthValidationError.passwordsDoNotMatch;
    }
    return null;
  }
}