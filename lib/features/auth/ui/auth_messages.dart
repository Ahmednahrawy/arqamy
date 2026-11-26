import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/domain/auth_validators.dart';
import 'package:arqamy/generated/l10n.dart';

/// The user-facing text for a failed account operation.
String authFailureMessage(S strings, AuthFailureCode code) {
  return switch (code) {
    AuthFailureCode.invalidEmail => strings.auth_email_invalid,
    AuthFailureCode.wrongCredentials => strings.auth_error_wrong_credentials,
    AuthFailureCode.userDisabled => strings.auth_error_user_disabled,
    AuthFailureCode.emailAlreadyInUse => strings.auth_error_email_in_use,
    AuthFailureCode.weakPassword => strings.auth_error_weak_password,
    AuthFailureCode.tooManyRequests => strings.auth_error_too_many_requests,
    AuthFailureCode.networkUnavailable => strings.auth_error_network,
    AuthFailureCode.serviceUnavailable =>
      strings.auth_error_service_unavailable,
    AuthFailureCode.unknown => strings.auth_error_unknown,
  };
}

/// The user-facing text for a form validation error, or null when valid.
String? authValidationMessage(S strings, AuthValidationError? error) {
  if (error == null) return null;
  return switch (error) {
    AuthValidationError.emailRequired => strings.auth_email_required,
    AuthValidationError.emailInvalid => strings.auth_email_invalid,
    AuthValidationError.passwordRequired => strings.auth_password_required,
    AuthValidationError.passwordTooShort =>
      strings.auth_password_too_short(AuthValidators.minPasswordLength),
    AuthValidationError.confirmPasswordRequired =>
      strings.auth_confirm_password_required,
    AuthValidationError.passwordsDoNotMatch =>
      strings.auth_passwords_do_not_match,
  };
}