import 'package:arqamy/core/widgets/info_card.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Static privacy screen. Content is informational only.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.privacy_policy)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: colors.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.privacy_intro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              icon: Icons.storage_outlined,
              title: strings.privacy_data_title,
              body: strings.privacy_data_body,
            ),
            const SizedBox(height: 12),
            InfoCard(
              icon: Icons.tune,
              title: strings.privacy_usage_title,
              body: strings.privacy_usage_body,
            ),
            const SizedBox(height: 12),
            InfoCard(
              icon: Icons.manage_accounts_outlined,
              title: strings.privacy_choices_title,
              body: strings.privacy_choices_body,
            ),
          ],
        ),
      ),
    );
  }
}
