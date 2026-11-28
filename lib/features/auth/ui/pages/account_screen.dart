import 'package:arqamy/core/widgets/language_picker_button.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/auth_flow.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Signed-in user's profile.
///
/// This is a demo scaffold: the rows below the account header are intentionally
/// inert and show a hint when tapped. Replace them with real profile editing
/// when those settings are implemented. Sign-out is fully wired.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profile),
        actions: const [LanguagePickerButton()],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 42,
            child: Text(_initials(email), style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              email,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              strings.demo_profile_note,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          _demoRow(context, icon: Icons.person_outline, title: strings.name),
          _demoRow(
            context,
            icon: Icons.lock_outline,
            title: strings.change_password,
          ),
          _demoRow(
            context,
            icon: Icons.notifications_none,
            title: strings.notifications,
          ),
          _demoRow(
            context,
            icon: Icons.privacy_tip_outlined,
            title: strings.privacy,
          ),
          _demoRow(context, icon: Icons.help_outline, title: strings.help),
          const Divider(),
          ListTile(
            key: const ValueKey('account-sign-out'),
            leading: const Icon(Icons.logout),
            title: Text(strings.logout),
            enabled: !auth.isBusy,
            onTap: () async {
              final signedOut = await confirmAndSignOut(context);
              if (signedOut && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _demoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      key: ValueKey('account-demo-$title'),
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).demo_profile_note)),
        );
      },
    );
  }

  /// Two-letter avatar label derived from the email's local part.
  String _initials(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return '?';
    return localPart.substring(0, localPart.length < 2 ? 1 : 2).toUpperCase();
  }
}
