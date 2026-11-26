import 'dart:async';

import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/domain/auth_user.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

Future<void> settle() => Future<void>.delayed(Duration.zero);

/// Records the email it receives, then behaves like the fake.
class _RecordingRepository extends FakeAuthRepository {
  String? lastSignInEmail;

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    lastSignInEmail = email;
    return super.signIn(email: email, password: password);
  }
}

/// Holds every sign-in open until [gate] completes.
class _GatedRepository extends FakeAuthRepository {
  final Completer<void> gate = Completer<void>();
  int signInCalls = 0;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    await gate.future;
    return super.signIn(email: email, password: password);
  }
}

/// Fails with an error that is not an [AuthException].
class _ThrowingRepository extends FakeAuthRepository {
  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    throw StateError('boom');
  }
}

void main() {
  late FakeAuthRepository repository;
  late AuthProvider provider;

  setUp(() {
    repository = FakeAuthRepository();
    provider = AuthProvider(repository);
    addTearDown(repository.dispose);
    addTearDown(provider.dispose);
  });

  test('starts signed out and idle', () {
    expect(provider.user, isNull);
    expect(provider.isSignedIn, isFalse);
    expect(provider.isBusy, isFalse);
    expect(provider.failure, isNull);
  });

  test('starts signed in when the repository already has a user', () async {
    final existing = FakeAuthRepository();
    addTearDown(existing.dispose);
    await existing.signUp(email: 'a@b.co', password: 'password1');

    final restored = AuthProvider(existing);
    addTearDown(restored.dispose);

    expect(restored.isSignedIn, isTrue);
    expect(restored.user?.email, 'a@b.co');
  });

  test('signUp signs the user in and notifies listeners', () async {
    var notifications = 0;
    provider.addListener(() => notifications++);

    final ok = await provider.signUp(email: 'a@b.co', password: 'password1');

    expect(ok, isTrue);
    expect(provider.isSignedIn, isTrue);
    expect(provider.user?.email, 'a@b.co');
    expect(provider.failure, isNull);
    expect(provider.isBusy, isFalse);
    expect(notifications, greaterThanOrEqualTo(2));
  });

  test('a failed signIn reports the failure code', () async {
    final ok = await provider.signIn(email: 'nobody@b.co', password: 'x');

    expect(ok, isFalse);
    expect(provider.failure, AuthFailureCode.wrongCredentials);
    expect(provider.user, isNull);
    expect(provider.isBusy, isFalse);
  });

  test('a new attempt clears the previous failure', () async {
    await provider.signIn(email: 'nobody@b.co', password: 'x');
    expect(provider.failure, isNotNull);

    final ok = await provider.signUp(email: 'a@b.co', password: 'password1');

    expect(ok, isTrue);
    expect(provider.failure, isNull);
  });

  test('clearFailure removes the failure and notifies once', () async {
    await provider.signIn(email: 'nobody@b.co', password: 'x');
    var notifications = 0;
    provider.addListener(() => notifications++);

    provider.clearFailure();
    provider.clearFailure();

    expect(provider.failure, isNull);
    expect(notifications, 1);
  });

  test('an unexpected error becomes the unknown failure', () async {
    final throwing = _ThrowingRepository();
    addTearDown(throwing.dispose);
    final throwingProvider = AuthProvider(throwing);
    addTearDown(throwingProvider.dispose);

    final ok = await throwingProvider.signIn(email: 'a@b.co', password: 'x');

    expect(ok, isFalse);
    expect(throwingProvider.failure, AuthFailureCode.unknown);
    expect(throwingProvider.isBusy, isFalse);
  });

  test('normalizes the email before calling the repository', () async {
    final recording = _RecordingRepository();
    addTearDown(recording.dispose);
    await recording.signUp(email: 'a@b.co', password: 'password1');
    await recording.signOut();
    final recordingProvider = AuthProvider(recording);
    addTearDown(recordingProvider.dispose);

    final ok = await recordingProvider.signIn(
      email: '  A@B.CO ',
      password: 'password1',
    );

    expect(ok, isTrue);
    expect(recording.lastSignInEmail, 'a@b.co');
  });

  test('sendPasswordReset succeeds without signing in', () async {
    final ok = await provider.sendPasswordReset(email: ' Nobody@B.co ');

    expect(ok, isTrue);
    expect(repository.passwordResetRequests, ['nobody@b.co']);
    expect(provider.isSignedIn, isFalse);
  });

  test('sendPasswordReset reports a backend failure', () async {
    repository.failNextWith = AuthFailureCode.networkUnavailable;

    final ok = await provider.sendPasswordReset(email: 'a@b.co');

    expect(ok, isFalse);
    expect(provider.failure, AuthFailureCode.networkUnavailable);
  });

  test('signOut clears the user', () async {
    await provider.signUp(email: 'a@b.co', password: 'password1');

    final ok = await provider.signOut();

    expect(ok, isTrue);
    expect(provider.isSignedIn, isFalse);
    expect(provider.user, isNull);
  });

  test('follows sign-in state changes made outside the provider', () async {
    final user = await repository.signUp(
      email: 'a@b.co',
      password: 'password1',
    );
    await settle();

    expect(provider.user, user);

    await repository.signOut();
    await settle();

    expect(provider.user, isNull);
  });

  test('ignores a second operation while one is running', () async {
    final gated = _GatedRepository();
    addTearDown(gated.dispose);
    await gated.signUp(email: 'a@b.co', password: 'password1');
    await gated.signOut();
    final gatedProvider = AuthProvider(gated);
    addTearDown(gatedProvider.dispose);

    final first = gatedProvider.signIn(email: 'a@b.co', password: 'password1');
    expect(gatedProvider.isBusy, isTrue);

    final second = await gatedProvider.signIn(
      email: 'a@b.co',
      password: 'password1',
    );
    expect(second, isFalse);
    expect(gated.signInCalls, 1);

    gated.gate.complete();

    expect(await first, isTrue);
    expect(gatedProvider.isBusy, isFalse);
    expect(gatedProvider.isSignedIn, isTrue);
  });

  test('finishing after dispose does not throw', () async {
    final gated = _GatedRepository();
    addTearDown(gated.dispose);
    await gated.signUp(email: 'a@b.co', password: 'password1');
    await gated.signOut();
    final disposedProvider = AuthProvider(gated);

    final pending = disposedProvider.signIn(
      email: 'a@b.co',
      password: 'password1',
    );
    disposedProvider.dispose();
    gated.gate.complete();

    expect(await pending, isTrue);
  });
}