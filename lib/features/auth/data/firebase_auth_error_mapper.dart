import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Maps a Firebase Auth error code to the backend-independent failure code.
///
/// Unknown accounts and wrong passwords share one code, so the app never
/// reveals whether an email address is registered.
AuthFailureCode mapFirebaseAuthCode(String code) {
  return switch (code) {
    'invalid-email' => AuthFailureCode.invalidEmail,
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' ||
    'invalid-login-credentials' => AuthFailureCode.wrongCredentials,
    'user-disabled' => AuthFailureCode.userDisabled,
    'email-already-in-use' => AuthFailureCode.emailAlreadyInUse,
    'weak-password' => AuthFailureCode.weakPassword,
    'too-many-requests' => AuthFailureCode.tooManyRequests,
    'network-request-failed' => AuthFailureCode.networkUnavailable,
    'operation-not-allowed' => AuthFailureCode.serviceUnavailable,
    _ => AuthFailureCode.unknown,
  };
}

/// Converts anything thrown by the Firebase SDK into an [AuthException].
AuthException toAuthException(Object error) {
  if (error is AuthException) return error;
  if (error is FirebaseAuthException) {
    return AuthException(mapFirebaseAuthCode(error.code));
  }
  if (error is FirebaseException) {
    // Other Firebase errors, for example `no-app` when initialization failed.
    return AuthException(
      error.code == 'network-request-failed'
          ? AuthFailureCode.networkUnavailable
          : AuthFailureCode.serviceUnavailable,
    );
  }
  return const AuthException(AuthFailureCode.unknown);
}