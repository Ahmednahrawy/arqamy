import 'package:arqamy/core/widgets/info_card.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Static help screen. Content is informational only.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.help)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.help_intro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.add_circle_outline,
              title: strings.help_create_invoice_title,
              body: strings.help_create_invoice_body,
            ),
            const SizedBox(height: 12),
            InfoCard(
              icon: Icons.backup_outlined,
              title: strings.help_backup_title,
              body: strings.help_backup_body,
            ),
            const SizedBox(height: 12),
            InfoCard(
              icon: Icons.restore,
              title: strings.help_restore_title,
              body: strings.help_restore_body,
            ),
            const SizedBox(height: 12),
            InfoCard(
              icon: Icons.language_outlined,
              title: strings.help_language_title,
              body: strings.help_language_body,
            ),
            const SizedBox(height: 12),
            InfoCard(
              icon: Icons.support_agent_outlined,
              title: strings.help_contact_title,
              body: strings.help_contact_body,
            ),
          ],
        ),
      ),
    );
  }
}
