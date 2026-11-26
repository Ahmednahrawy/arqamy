import 'package:arqamy/features/auth/domain/auth_validators.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/auth_messages.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Email and password account creation.
///
/// Like the login screen, it does not navigate. It reports what happened
/// through callbacks and needs an [AuthProvider] above it in the widget tree.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.onSignedUp,
    required this.onHaveAccount,
  });

  /// Called after the account was created and the user is signed in.
  final VoidCallback onSignedUp;

  /// Called when the user asks to sign in with an existing account instead.
  final VoidCallback onHaveAccount;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePasswords = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<AuthProvider>();
    if (provider.isBusy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await provider.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) widget.onSignedUp();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final failure = auth.failure;

    return Scaffold(
      appBar: AppBar(title: Text(strings.auth_sign_up)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.auth_sign_up,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const ValueKey('signup-email'),
                        controller: _emailController,
                        enabled: !auth.isBusy,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: strings.auth_email,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => auth.clearFailure(),
                        validator: (value) => authValidationMessage(
                          strings,
                          AuthValidators.validateEmail(value),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('signup-password'),
                        controller: _passwordController,
                        enabled: !auth.isBusy,
                        obscureText: _obscurePasswords,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: strings.auth_password,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            key: const ValueKey('signup-toggle-password'),
                            tooltip: _obscurePasswords
                                ? strings.auth_show_password
                                : strings.auth_hide_password,
                            icon: Icon(
                              _obscurePasswords
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePasswords = !_obscurePasswords,
                            ),
                          ),
                        ),
                        onChanged: (_) => auth.clearFailure(),
                        validator: (value) => authValidationMessage(
                          strings,
                          AuthValidators.validateNewPassword(value),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('signup-confirm'),
                        controller: _confirmController,
                        enabled: !auth.isBusy,
                        obscureText: _obscurePasswords,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: strings.auth_confirm_password,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => auth.clearFailure(),
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) => authValidationMessage(
                          strings,
                          AuthValidators.validateConfirmation(
                            _passwordController.text,
                            value,
                          ),
                        ),
                      ),
                      if (failure != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            key: const ValueKey('signup-error'),
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
                        key: const ValueKey('signup-submit'),
                        onPressed: auth.isBusy ? null : _submit,
                        child: auth.isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(strings.auth_sign_up),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(strings.auth_have_account),
                          TextButton(
                            key: const ValueKey('signup-have-account'),
                            onPressed:
                                auth.isBusy ? null : widget.onHaveAccount,
                            child: Text(strings.auth_sign_in),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}