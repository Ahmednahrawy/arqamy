/// The signed-in account, independent of the authentication backend.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    this.emailVerified = false,
  });

  final String uid;
  final String email;
  final bool emailVerified;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.uid == uid &&
      other.email == email &&
      other.emailVerified == emailVerified;

  @override
  int get hashCode => Object.hash(uid, email, emailVerified);

  @override
  String toString() => 'AuthUser(uid: $uid)';
}