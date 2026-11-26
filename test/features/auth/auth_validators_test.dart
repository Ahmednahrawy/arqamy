import 'package:arqamy/features/auth/domain/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeEmail', () {
    test('trims and lower-cases', () {
      expect(
        AuthValidators.normalizeEmail('  User@Example.COM '),
        'user@example.com',
      );
    });

    test('treats null as empty', () {
      expect(AuthValidators.normalizeEmail(null), '');
    });
  });

  group('validateEmail', () {
    test('requires a value', () {
      expect(
        AuthValidators.validateEmail(null),
        AuthValidationError.emailRequired,
      );
      expect(
        AuthValidators.validateEmail(''),
        AuthValidationError.emailRequired,
      );
      expect(
        AuthValidators.validateEmail('   '),
        AuthValidationError.emailRequired,
      );
    });

    test('accepts ordinary addresses, ignoring surrounding spaces', () {
      expect(AuthValidators.validateEmail('a@b.co'), isNull);
      expect(AuthValidators.validateEmail(' user@example.com '), isNull);
      expect(AuthValidators.validateEmail('first.last+tag@mail.example.com'),
          isNull);
    });

    test('rejects malformed addresses', () {
      for (final value in [
        'user',
        'user@',
        '@example.com',
        'user@example',
        'user example@mail.com',
        'user@@example.com',
        'user@exa mple.com',
      ]) {
        expect(
          AuthValidators.validateEmail(value),
          AuthValidationError.emailInvalid,
          reason: value,
        );
      }
    });

    test('rejects an address longer than the maximum', () {
      final tooLong = '${'a' * 250}@b.co';
      expect(
        AuthValidators.validateEmail(tooLong),
        AuthValidationError.emailInvalid,
      );
    });
  });

  group('validateLoginPassword', () {
    test('requires a value', () {
      expect(
        AuthValidators.validateLoginPassword(null),
        AuthValidationError.passwordRequired,
      );
      expect(
        AuthValidators.validateLoginPassword(''),
        AuthValidationError.passwordRequired,
      );
    });

    test('does not enforce the new-password length', () {
      expect(AuthValidators.validateLoginPassword('abc'), isNull);
    });
  });

  group('validateNewPassword', () {
    test('requires a value', () {
      expect(
        AuthValidators.validateNewPassword(null),
        AuthValidationError.passwordRequired,
      );
      expect(
        AuthValidators.validateNewPassword(''),
        AuthValidationError.passwordRequired,
      );
    });

    test('enforces the minimum length', () {
      expect(
        AuthValidators.validateNewPassword('1234567'),
        AuthValidationError.passwordTooShort,
      );
      expect(AuthValidators.validateNewPassword('12345678'), isNull);
    });

    test('does not trim the password', () {
      expect(AuthValidators.validateNewPassword('  abc   '), isNull);
    });
  });

  group('validateConfirmation', () {
    test('requires a value', () {
      expect(
        AuthValidators.validateConfirmation('password1', null),
        AuthValidationError.confirmPasswordRequired,
      );
      expect(
        AuthValidators.validateConfirmation('password1', ''),
        AuthValidationError.confirmPasswordRequired,
      );
    });

    test('must match exactly, including case', () {
      expect(
        AuthValidators.validateConfirmation('Password1', 'password1'),
        AuthValidationError.passwordsDoNotMatch,
      );
      expect(AuthValidators.validateConfirmation('password1', 'password1'),
          isNull);
    });
  });
}