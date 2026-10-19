import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/providers/language.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/features/settingscreen/ui/pages/invoice_setting.dart';
import 'package:arqamy/features/settingscreen/ui/pages/product_management.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
          // Invoice Management Section
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              S.of(context).invoice_management,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ),

          // Invoice Templates
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blue),
            title:  Text(S.of(context).invoice_template),
            subtitle:  Text(S.of(context).invoice_templated_desc),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvoiceSettingsScreen(),
                  ));
            },
          ),
          const Divider(),
            // NEW: Product Management
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Colors.blue),
            title: const Text('إدارة المنتجات'), // Product Management
            subtitle: const Text('إضافة وتعديل وحذف المنتجات'), // Add, edit and delete products
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
          // 👇 New Dark Mode Toggle
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(S.of(context).dark_mode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          // 👇 Language Toggle
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.of(context).language),
            trailing: DropdownButton<String>(
              elevation: 8,
              iconSize: size.height / 30,
              borderRadius: BorderRadius.circular(15),
              value: languageProvider.currentLocale.languageCode,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              dropdownColor: LightColors.background,
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
