import 'package:arqamy/features/auth/data/firebase_auth_error_mapper.dart';
import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapFirebaseAuthCode', () {
    const expected = <String, AuthFailureCode>{
      'invalid-email': AuthFailureCode.invalidEmail,
      'user-not-found': AuthFailureCode.wrongCredentials,
      'wrong-password': AuthFailureCode.wrongCredentials,
      'invalid-credential': AuthFailureCode.wrongCredentials,
      'invalid-login-credentials': AuthFailureCode.wrongCredentials,
      'user-disabled': AuthFailureCode.userDisabled,
      'email-already-in-use': AuthFailureCode.emailAlreadyInUse,
      'weak-password': AuthFailureCode.weakPassword,
      'too-many-requests': AuthFailureCode.tooManyRequests,
      'network-request-failed': AuthFailureCode.networkUnavailable,
      'operation-not-allowed': AuthFailureCode.serviceUnavailable,
    };

    expected.forEach((code, failure) {
      test('maps $code to ${failure.name}', () {
        expect(mapFirebaseAuthCode(code), failure);
      });
    });

    test('maps an unrecognized code to unknown', () {
      expect(mapFirebaseAuthCode('something-new'), AuthFailureCode.unknown);
    });
  });

  group('toAuthException', () {
    test('maps a FirebaseAuthException by its code', () {
      final result = toAuthException(
        FirebaseAuthException(code: 'wrong-password'),
      );

      expect(result.code, AuthFailureCode.wrongCredentials);
    });

    test('reports an uninitialized Firebase as serviceUnavailable', () {
      final result = toAuthException(
        FirebaseException(plugin: 'core', code: 'no-app'),
      );

      expect(result.code, AuthFailureCode.serviceUnavailable);
    });

    test('reports a Firebase network error as networkUnavailable', () {
      final result = toAuthException(
        FirebaseException(plugin: 'core', code: 'network-request-failed'),
      );

      expect(result.code, AuthFailureCode.networkUnavailable);
    });

    test('passes an AuthException through unchanged', () {
      const original = AuthException(AuthFailureCode.tooManyRequests);

      expect(identical(toAuthException(original), original), isTrue);
    });

    test('maps any other error to unknown', () {
      expect(toAuthException(StateError('boom')).code, AuthFailureCode.unknown);
    });
  });
}