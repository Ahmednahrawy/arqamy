import 'dart:async';

import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/domain/auth_repository.dart';
import 'package:arqamy/features/auth/domain/auth_user.dart';
import 'package:arqamy/features/auth/domain/auth_validators.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the sign-in state and runs account operations for the auth screens.
///
/// Each operation returns true on success. On failure it returns false and
/// sets [failure], which the UI maps to a localized message. While an
/// operation runs, [isBusy] is true and further operations are ignored, so a
/// double tap on a submit button cannot send two requests.
class AuthProvider extends ChangeNotifier {
  /// Saved preference that lets the app be used without an account.
  static const String skipSignInKey = 'auth_skip_sign_in';

  AuthProvider(AuthRepository repository)
    : _repository = repository,
      _user = repository.currentUser {
    _subscription = _repository.authStateChanges().listen(
      _onAuthState,
      onError: (Object error) {},
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthUser?> _subscription;

  AuthUser? _user;
  bool _isBusy = false;
  bool _disposed = false;
  bool _skipped = false;
  AuthFailureCode? _failure;

  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;

  /// True when the user chose to continue without signing in.
  bool get isSkipped => _skipped;

  /// Whether the app may be opened, with an account or as a guest.
  bool get canUseApp => isSignedIn || _skipped;

  bool get isBusy => _isBusy;

  /// The reason the last operation failed, or null.
  AuthFailureCode? get failure => _failure;

  Future<bool> signIn({required String email, required String password}) {
    return _run(() async {
      _user = await _repository.signIn(
        email: AuthValidators.normalizeEmail(email),
        password: password,
      );
      await _clearSkipPreference();
    });
  }

  Future<bool> signUp({required String email, required String password}) {
    return _run(() async {
      _user = await _repository.signUp(
        email: AuthValidators.normalizeEmail(email),
        password: password,
      );
      await _clearSkipPreference();
    });
  }

  Future<bool> sendPasswordReset({required String email}) {
    return _run(
      () => _repository.sendPasswordReset(
        email: AuthValidators.normalizeEmail(email),
      ),
    );
  }

  Future<bool> signOut() {
    return _run(() async {
      await _repository.signOut();
      _user = null;
      await _clearSkipPreference();
    });
  }

  /// Restores the saved "continue without signing in" choice at startup.
  Future<void> loadSkipPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _skipped = prefs.getBool(skipSignInKey) ?? false;
    } catch (_) {
      _skipped = false;
    }
    _notify();
  }

  /// Enters the app as a guest and remembers the choice for next launch.
  Future<void> skipSignIn() async {
    if (_skipped) return;
    _skipped = true;
    // Switch to the app immediately; persistence can finish in the background.
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(skipSignInKey, true);
    } catch (_) {
      // The in-memory choice still works for this session.
    }
  }

  Future<void> _clearSkipPreference() async {
    if (!_skipped) return;
    _skipped = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(skipSignInKey);
    } catch (_) {
      // The in-memory state is already cleared.
    }
  }

  /// Lets a form hide an old error as soon as the user edits a field.
  void clearFailure() {
    if (_failure == null) return;
    _failure = null;
    _notify();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_isBusy) return false;
    _isBusy = true;
    _failure = null;
    _notify();
    try {
      await action();
      return true;
    } on AuthException catch (error) {
      _failure = error.code;
      return false;
    } catch (_) {
      _failure = AuthFailureCode.unknown;
      return false;
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  void _onAuthState(AuthUser? user) {
    if (user == _user) return;
    _user = user;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
