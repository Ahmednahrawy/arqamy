import 'package:arqamy/core/widgets/language_picker_button.dart';
import 'package:arqamy/features/auth/domain/auth_validators.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/auth_messages.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Email and password sign-in.
///
/// The screen does not navigate. It reports what happened through callbacks,
/// so the caller decides where each one leads. It needs an [AuthProvider]
/// above it in the widget tree.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onSignedIn,
    required this.onCreateAccount,
    required this.onForgotPassword,
    this.onSkip,
  });

  final VoidCallback onSignedIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;

  /// When supplied, shows a Skip action so the app can be used as a guest.
  final VoidCallback? onSkip;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<AuthProvider>();
    if (provider.isBusy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await provider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) widget.onSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final failure = auth.failure;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.auth_sign_in),
        actions: [
          if (widget.onSkip != null)
            TextButton(
              key: const ValueKey('login-skip'),
              onPressed: widget.onSkip,
              child: Text(strings.skip),
            ),
          const LanguagePickerButton(),
        ],
      ),
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
                        Icons.lock_outline,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.auth_sign_in,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const ValueKey('login-email'),
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
                        key: const ValueKey('login-password'),
                        controller: _passwordController,
                        enabled: !auth.isBusy,
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: strings.auth_password,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            key: const ValueKey('login-toggle-password'),
                            tooltip: _obscurePassword
                                ? strings.auth_show_password
                                : strings.auth_hide_password,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        onChanged: (_) => auth.clearFailure(),
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) => authValidationMessage(
                          strings,
                          AuthValidators.validateLoginPassword(value),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          key: const ValueKey('login-forgot'),
                          onPressed: auth.isBusy
                              ? null
                              : widget.onForgotPassword,
                          child: Text(strings.auth_forgot_password),
                        ),
                      ),
                      if (failure != null) ...[
                        const SizedBox(height: 8),
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            key: const ValueKey('login-error'),
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
                        key: const ValueKey('login-submit'),
                        onPressed: auth.isBusy ? null : _submit,
                        child: auth.isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(strings.auth_sign_in),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(strings.auth_no_account),
                          TextButton(
                            key: const ValueKey('login-create-account'),
                            onPressed: auth.isBusy
                                ? null
                                : widget.onCreateAccount,
                            child: Text(strings.auth_sign_up),
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
