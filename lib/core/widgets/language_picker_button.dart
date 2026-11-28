import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Compact language switcher for app bars.
///
/// The provider is watched as nullable so an auth screen can still be shown
/// on its own (for example in a widget test) without a [Language] above it.
/// In the running app the provider is always present and the button appears.
class LanguagePickerButton extends StatelessWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<Language?>();
    if (language == null) return const SizedBox.shrink();

    final strings = S.of(context);
    final colors = Theme.of(context).colorScheme;
    final currentCode = language.currentLocale.languageCode;

    return PopupMenuButton<String>(
      key: const ValueKey('language-picker'),
      tooltip: strings.language,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: language.switchLanguage,
      itemBuilder: (context) => [
        for (final option in language.languageOptions)
          PopupMenuItem<String>(
            value: option['code']!,
            child: Row(
              children: [
                Icon(
                  option['code'] == currentCode
                      ? Icons.check
                      : Icons.language_outlined,
                  size: 18,
                  color: option['code'] == currentCode
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  option['code'] == 'ar' ? strings.arabic : strings.english,
                  style: TextStyle(fontSize: 14, color: colors.onSurface),
                ),
              ],
            ),
          ),
      ],
      icon: const Icon(Icons.language),
    );
  }
}
