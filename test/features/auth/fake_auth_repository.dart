import 'dart:async';

import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/domain/auth_repository.dart';
import 'package:arqamy/features/auth/domain/auth_user.dart';

/// In-memory [AuthRepository] for tests.
///
/// It behaves the way the real backend is expected to: emails are
/// case-insensitive, unknown accounts and wrong passwords give the same
/// failure, and password reset never reveals whether an account exists.
class FakeAuthRepository implements AuthRepository {
  /// The shortest password the backend itself accepts.
  static const int minBackendPasswordLength = 6;

  final Map<String, String> _passwordsByEmail = {};
  final Map<String, String> _uidsByEmail = {};
  final StreamController<AuthUser?> _changes =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;
  int _nextUid = 1;

  /// When set, the next sign-in, sign-up or password-reset call fails with
  /// this code. The setting clears itself after that one call.
  AuthFailureCode? failNextWith;

  /// Normalized emails passed to [sendPasswordReset], in call order.
  final List<String> passwordResetRequests = <String>[];

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _changes.stream;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    _throwInjectedFailure();
    final key = _normalize(email);
    final stored = _passwordsByEmail[key];
    if (stored == null || stored != password) {
      throw const AuthException(AuthFailureCode.wrongCredentials);
    }
    return _setCurrent(AuthUser(uid: _uidsByEmail[key]!, email: key));
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    _throwInjectedFailure();
    final key = _normalize(email);
    if (!key.contains('@')) {
      throw const AuthException(AuthFailureCode.invalidEmail);
    }
    if (_passwordsByEmail.containsKey(key)) {
      throw const AuthException(AuthFailureCode.emailAlreadyInUse);
    }
    if (password.length < minBackendPasswordLength) {
      throw const AuthException(AuthFailureCode.weakPassword);
    }
    final uid = 'uid-${_nextUid++}';
    _passwordsByEmail[key] = password;
    _uidsByEmail[key] = uid;
    return _setCurrent(AuthUser(uid: uid, email: key));
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    _throwInjectedFailure();
    passwordResetRequests.add(_normalize(email));
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();

  AuthUser _setCurrent(AuthUser user) {
    _currentUser = user;
    _changes.add(user);
    return user;
  }

  String _normalize(String email) => email.trim().toLowerCase();

  void _throwInjectedFailure() {
    final failure = failNextWith;
    if (failure == null) return;
    failNextWith = null;
    throw AuthException(failure);
  }
}