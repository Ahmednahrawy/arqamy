import 'package:arqamy/features/auth/data/firebase_auth_error_mapper.dart';
import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/domain/auth_repository.dart';
import 'package:arqamy/features/auth/domain/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// [AuthRepository] backed by Firebase Authentication (email and password).
///
/// `FirebaseAuth.instance` is read lazily. The app starts even when Firebase
/// failed to initialize, and then every operation fails with
/// [AuthFailureCode.serviceUnavailable] instead of crashing.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth}) : _injectedAuth = auth;

  final FirebaseAuth? _injectedAuth;

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  @override
  AuthUser? get currentUser {
    try {
      return _toAuthUser(_auth.currentUser);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    try {
      return _auth.authStateChanges().map(_toAuthUser);
    } catch (_) {
      // Firebase is unavailable: behave as signed out.
      return Stream<AuthUser?>.value(null);
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } catch (error) {
      throw toAuthException(error);
    }
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } catch (error) {
      throw toAuthException(error);
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      final failure = toAuthException(error);
      // Never reveal whether an account exists.
      if (failure.code == AuthFailureCode.wrongCredentials) return;
      throw failure;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      throw toAuthException(error);
    }
  }

  AuthUser _requireUser(User? user) {
    final mapped = _toAuthUser(user);
    if (mapped == null) throw const AuthException(AuthFailureCode.unknown);
    return mapped;
  }

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      emailVerified: user.emailVerified,
    );
  }
}