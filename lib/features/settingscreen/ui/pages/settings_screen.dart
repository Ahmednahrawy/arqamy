import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/settingscreen/ui/pages/invoice_setting.dart';
import 'package:arqamy/features/settingscreen/ui/pages/product_management.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<Language>(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(S.of(context).profile),
            onTap: () {
              // Handle account tap
            },
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              S.of(context).invoice_management,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(S.of(context).invoice_template),
            subtitle: Text(S.of(context).invoice_templated_desc),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvoiceSettingsScreen(),
                  ));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('إدارة المنتجات'),
            subtitle: const Text('إضافة وتعديل وحذف المنتجات'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(S.of(context).notifications),
            onTap: () {
              // Handle notifications tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(S.of(context).privacy),
            onTap: () {
              // Handle privacy tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(S.of(context).help),
            onTap: () {
              // Handle help tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(S.of(context).appearance),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(S.of(context).light_mode),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(S.of(context).dark_mode),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(S.of(context).system_mode),
                ),
              ],
              onChanged: (mode) async {
                if (mode == null) return;
                try {
                  await themeProvider.setThemeMode(mode);
                } catch (error) {
                  if (!context.mounted) return;
                  showAppSnackBar(
                    context,
                    languageProvider.isArabic
                        ? 'تعذر حفظ إعداد المظهر: $error'
                        : 'Could not save appearance setting: $error',
                    isError: true,
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.of(context).language),
            trailing: DropdownButton<String>(
              elevation: 8,
              iconSize: size.height / 30,
              borderRadius: BorderRadius.circular(15),
              value: languageProvider.currentLocale.languageCode,
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Theme.of(context).colorScheme.surface,
              underline: const SizedBox(),
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  languageProvider.switchLanguage(newLanguage);
                }
              },
              items: languageProvider.languageOptions.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Text(lang['text']!),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(S.of(context).logout),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
