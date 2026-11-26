import 'package:arqamy/features/auth/domain/auth_user.dart';

/// Account operations the app needs, independent of the backend.
///
/// Implementations must report every failure as an `AuthException`. They must
/// not let backend-specific exceptions escape.
abstract class AuthRepository {
  /// The signed-in user, or null when signed out.
  AuthUser? get currentUser;

  /// Emits the current state first, then every sign-in and sign-out.
  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> signUp({required String email, required String password});

  /// Succeeds even when the email has no account, so the app never reveals
  /// which addresses are registered.
  Future<void> sendPasswordReset({required String email});

  Future<void> signOut();
}