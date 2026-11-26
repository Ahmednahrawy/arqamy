import 'package:arqamy/features/auth/domain/auth_validators.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/auth_messages.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Asks for an email address and requests a password-reset link.
///
/// After a successful request the screen shows the same confirmation whether
/// or not the address has an account, so it never reveals who is registered.
/// It does not navigate; the caller handles [onBackToSignIn]. It needs an
/// [AuthProvider] above it in the widget tree.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.onBackToSignIn});

  final VoidCallback onBackToSignIn;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _linkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<AuthProvider>();
    if (provider.isBusy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _linkSent = false);

    final ok = await provider.sendPasswordReset(email: _emailController.text);
    if (!mounted) return;
    if (ok) setState(() => _linkSent = true);
  }

  void _onEmailChanged(AuthProvider auth) {
    auth.clearFailure();
    if (_linkSent) setState(() => _linkSent = false);
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final failure = auth.failure;

    return Scaffold(
      appBar: AppBar(title: Text(strings.auth_reset_password_title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.auth_reset_password_title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.auth_reset_password_intro,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const ValueKey('reset-email'),
                      controller: _emailController,
                      enabled: !auth.isBusy,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: strings.auth_email,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => _onEmailChanged(auth),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) => authValidationMessage(
                        strings,
                        AuthValidators.validateEmail(value),
                      ),
                    ),
                    if (_linkSent) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          key: const ValueKey('reset-sent'),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            strings.auth_reset_link_sent,
                            style: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (failure != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          key: const ValueKey('reset-error'),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authFailureMessage(strings, failure),
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const ValueKey('reset-submit'),
                      onPressed: auth.isBusy ? null : _submit,
                      child: auth.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(strings.auth_send_reset_link),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const ValueKey('reset-back'),
                      onPressed: auth.isBusy ? null : widget.onBackToSignIn,
                      child: Text(strings.auth_sign_in),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}