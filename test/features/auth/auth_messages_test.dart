import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/domain/auth_validators.dart';
import 'package:arqamy/features/auth/ui/auth_messages.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in S.delegate.supportedLocales) {
    test('every failure and validation error has text in $locale', () async {
      final strings = await S.delegate.load(locale);

      for (final code in AuthFailureCode.values) {
        expect(authFailureMessage(strings, code), isNotEmpty, reason: code.name);
      }
      for (final error in AuthValidationError.values) {
        expect(
          authValidationMessage(strings, error),
          isNotEmpty,
          reason: error.name,
        );
      }
      expect(authValidationMessage(strings, null), isNull);
    });
  }
}