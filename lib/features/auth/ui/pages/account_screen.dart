import 'package:arqamy/core/widgets/language_picker_button.dart';
import 'package:arqamy/features/auth/providers/auth_provider.dart';
import 'package:arqamy/features/auth/ui/auth_flow.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// The signed-in user's profile: the email address and a sign-out entry.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profile),
        actions: const [LanguagePickerButton()],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(strings.auth_email),
            subtitle: Text(
              auth.user?.email ?? '',
              textDirection: TextDirection.ltr,
            ),
          ),
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
}
