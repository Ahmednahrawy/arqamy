import 'package:arqamy/core/widgets/language_picker_button.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Demo profile settings screen.
///
/// Every row is a placeholder to be wired up with real settings later.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profile),
        actions: const [LanguagePickerButton()],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 42,
            child: Icon(Icons.person_outline, size: 42),
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
}
