import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/domain/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

Matcher throwsAuthFailure(AuthFailureCode code) => throwsA(
  isA<AuthException>().having((error) => error.code, 'code', code),
);

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeAuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
    addTearDown(repository.dispose);
  });

  test('AuthUser compares by value', () {
    expect(
      const AuthUser(uid: 'u1', email: 'a@b.co'),
      const AuthUser(uid: 'u1', email: 'a@b.co'),
    );
    expect(
      const AuthUser(uid: 'u1', email: 'a@b.co'),
      isNot(const AuthUser(uid: 'u2', email: 'a@b.co')),
    );
  });

  group('signUp', () {
    test('creates the account and signs in with a normalized email', () async {
      final user = await repository.signUp(
        email: '  New@Example.com ',
        password: 'password1',
      );

      expect(user.email, 'new@example.com');
      expect(repository.currentUser, user);
    });

    test('rejects a duplicate email, ignoring case', () async {
      await repository.signUp(email: 'a@b.co', password: 'password1');

      await expectLater(
        repository.signUp(email: 'A@B.CO', password: 'password2'),
        throwsAuthFailure(AuthFailureCode.emailAlreadyInUse),
      );
    });

    test('rejects a password the backend considers weak', () async {
      await expectLater(
        repository.signUp(email: 'a@b.co', password: '12345'),
        throwsAuthFailure(AuthFailureCode.weakPassword),
      );
      expect(repository.currentUser, isNull);
    });

    test('rejects an address without an at sign', () async {
      await expectLater(
        repository.signUp(email: 'not-an-email', password: 'password1'),
        throwsAuthFailure(AuthFailureCode.invalidEmail),
      );
    });
  });

  group('signIn', () {
    setUp(() async {
      await repository.signUp(email: 'a@b.co', password: 'password1');
      await repository.signOut();
    });

    test('succeeds with the right password, ignoring email case', () async {
      final user = await repository.signIn(
        email: 'A@B.co',
        password: 'password1',
      );

      expect(user.email, 'a@b.co');
      expect(repository.currentUser, user);
    });

    test('gives the same failure for a wrong password and unknown email',
        () async {
      await expectLater(
        repository.signIn(email: 'a@b.co', password: 'wrong'),
        throwsAuthFailure(AuthFailureCode.wrongCredentials),
      );
      await expectLater(
        repository.signIn(email: 'nobody@b.co', password: 'password1'),
        throwsAuthFailure(AuthFailureCode.wrongCredentials),
      );
      expect(repository.currentUser, isNull);
    });
  });

  group('sendPasswordReset', () {
    test('does not reveal whether the account exists', () async {
      await repository.sendPasswordReset(email: ' Nobody@B.co ');

      expect(repository.passwordResetRequests, ['nobody@b.co']);
    });
  });

  group('failNextWith', () {
    test('fails exactly one call', () async {
      repository.failNextWith = AuthFailureCode.networkUnavailable;

      await expectLater(
        repository.signUp(email: 'a@b.co', password: 'password1'),
        throwsAuthFailure(AuthFailureCode.networkUnavailable),
      );

      final user = await repository.signUp(
        email: 'a@b.co',
        password: 'password1',
      );
      expect(repository.currentUser, user);
    });
  });

  test('authStateChanges emits the current state, then each change', () async {
    final states = <AuthUser?>[];
    final subscription = repository.authStateChanges().listen(states.add);
    addTearDown(subscription.cancel);
    await settle();

    final user = await repository.signUp(
      email: 'a@b.co',
      password: 'password1',
    );
    await settle();
    await repository.signOut();
    await settle();

    expect(states, [null, user, null]);
    expect(repository.currentUser, isNull);
  });
}