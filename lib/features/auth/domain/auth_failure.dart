/// Reasons an authentication request can fail, independent of the backend.
///
/// Presentation code maps each code to a localized message, so raw backend
/// error text never reaches the user.
enum AuthFailureCode {
  invalidEmail,

  /// Wrong password or unknown account. Deliberately one code, so the app
  /// never reveals whether an email address has an account.
  wrongCredentials,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  networkUnavailable,

  /// The backend is not initialized or the sign-in method is not enabled.
  serviceUnavailable,
  unknown,
}

/// The only exception an [AuthRepository] may throw.
class AuthException implements Exception {
  const AuthException(this.code);

  final AuthFailureCode code;

  @override
  String toString() => 'AuthException(${code.name})';
}