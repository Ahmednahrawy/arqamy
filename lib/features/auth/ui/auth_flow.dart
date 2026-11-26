import 'package:arqamy/features/auth/domain/auth_failure.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/auth_messages.dart';
import 'package:arqamy/features/auth/ui/pages/forgot_password_screen.dart';
import 'package:arqamy/features/auth/ui/pages/login_screen.dart';
import 'package:arqamy/features/auth/ui/pages/sign_up_screen.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Opens the sign-in flow: login, with sign-up and password reset reachable
/// from it. Resolves to true when the user ended up signed in, and to false
/// when they backed out.
Future<bool> openAuthFlow(BuildContext context) async {
  final signedIn = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (loginContext) => LoginScreen(
        onSignedIn: () => Navigator.of(loginContext).pop(true),
        onCreateAccount: () => _openSignUp(loginContext),
        onForgotPassword: () => _openForgotPassword(loginContext),
      ),
    ),
  );
  return signedIn ?? false;
}

Future<void> _openSignUp(BuildContext loginContext) async {
  final created = await Navigator.of(loginContext).push<bool>(
    MaterialPageRoute<bool>(
      builder: (signUpContext) => SignUpScreen(
        onSignedUp: () => Navigator.of(signUpContext).pop(true),
        onHaveAccount: () => Navigator.of(signUpContext).pop(false),
      ),
    ),
  );
  if (created == true && loginContext.mounted) {
    Navigator.of(loginContext).pop(true);
  }
}

Future<void> _openForgotPassword(BuildContext loginContext) {
  return Navigator.of(loginContext).push<void>(
    MaterialPageRoute<void>(
      builder: (resetContext) => ForgotPasswordScreen(
        onBackToSignIn: () => Navigator.of(resetContext).pop(),
      ),
    ),
  );
}

/// Asks the user to confirm, then signs out. Resolves to true when the user
/// was signed out. A failed sign-out shows a message and resolves to false.
Future<bool> confirmAndSignOut(BuildContext context) async {
  final strings = S.of(context);
  final provider = context.read<AuthProvider>();
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(strings.logout),
      content: Text(strings.are_you_sure_logout),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(strings.logout),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  final signedOut = await provider.signOut();
  if (!signedOut) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          authFailureMessage(
            strings,
            provider.failure ?? AuthFailureCode.unknown,
          ),
        ),
      ),
    );
  }
  return signedOut;
}