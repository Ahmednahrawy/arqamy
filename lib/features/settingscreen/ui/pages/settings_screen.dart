import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/customerscreen/data/customer_linking_service.dart';
import 'package:arqamy/core/providers/theme.dart';
import 'package:arqamy/core/services/invoice_backup_service.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_import_service.dart';
import 'package:arqamy/features/settingscreen/ui/pages/invoice_setting.dart';
import 'package:arqamy/features/settingscreen/ui/pages/product_management.dart';
import 'package:arqamy/features/settingscreen/ui/widgets/settings_actions_dropdown.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _backupInvoices(BuildContext context) async {
    final strings = S.of(context);
    final provider = context.read<InvoiceProvider>();
    try {
      final count = await InvoiceBackupService.shareBackup(provider);
      if (!context.mounted) return;
      if (count == 0) {
        showAppSnackBar(context, strings.backup_no_invoices);
      }
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        '${strings.backup_failed}: $error',
        isError: true,
      );
    }
  }

  Future<void> _restoreInvoices(BuildContext context) async {
    final strings = S.of(context);
    final provider = context.read<InvoiceProvider>();
    try {
      final text = await InvoiceBackupService.pickBackupText();
      if (text == null || !context.mounted) return;

      // Reload so the preview compares against what is really saved.
      await provider.loadInvoices();
      final preview = provider.previewRestore(text);
      if (!context.mounted) return;
      if (preview.total == 0) {
        showAppSnackBar(context, strings.restore_empty_backup);
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.restore_invoices),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.restore_confirm_message),
              const SizedBox(height: 12),
              Text('${strings.restore_new_invoices}: ${preview.added}'),
              Text('${strings.restore_replaced_invoices}: ${preview.replaced}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.restore_action),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      await provider.restoreBackup(text);
      if (!context.mounted) return;
      showAppSnackBar(context, strings.restore_done);
    } on InvoiceBackupFormatException catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        '${strings.restore_invalid_backup}: ${error.message}',
        isError: true,
      );
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        '${strings.restore_failed}: $error',
        isError: true,
      );
    }
  }

  Future<void> _linkCustomers(BuildContext context) async {
    final strings = S.of(context);
    final provider = context.read<InvoiceProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.link_customers),
        content: Text(strings.link_customers_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.link_customers_action),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final result = await CustomerLinkingService.linkCustomers(provider);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.link_customers),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${strings.link_customers_linked}: ${result.invoicesLinked}',
              ),
              Text(
                '${strings.link_customers_created}: ${result.customersCreated}',
              ),
              Text(
                '${strings.link_customers_reused}: ${result.customersReused}',
              ),
              Text(
                '${strings.link_customers_need_confirmation}: '
                '${result.groupsNeedingConfirmation}',
              ),
              Text(
                '${strings.link_customers_unnamed}: ${result.unnamedInvoices}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.confirm),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        '${strings.link_customers_failed}: $error',
        isError: true,
      );
    }
  }

  Future<void> _importToLedger(BuildContext context) async {
    final strings = S.of(context);
    final provider = context.read<InvoiceProvider>();
    try {
      final plan = await LedgerImportService.preview(provider);
      if (!context.mounted) return;
      if (plan.ready.isEmpty) {
        showAppSnackBar(context, strings.ledger_import_nothing);
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.ledger_import),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.ledger_import_confirm),
              const SizedBox(height: 12),
              Text('${strings.ledger_import_ready}: ${plan.ready.length}'),
              Text('${strings.ledger_import_held}: ${plan.held.length}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.ledger_import_action),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final result = await LedgerImportService.run(provider, plan);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.ledger_import),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${strings.ledger_import_imported}: ${result.invoicesImported}',
              ),
              Text(
                '${strings.ledger_import_already}: '
                '${result.invoicesAlreadyImported}',
              ),
              Text(
                '${strings.ledger_import_missing_customer}: '
                '${result.skippedMissingParty}',
              ),
              Text(
                '${strings.ledger_import_accounts}: ${result.accountsCreated}',
              ),
              Text('${strings.ledger_import_held}: ${result.held}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.confirm),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        '${strings.ledger_import_failed}: $error',
        isError: true,
      );
    }
  }

  void _openAction(BuildContext context, SettingsAction action) {
    switch (action) {
      case SettingsAction.backupInvoices:
        _backupInvoices(context);
        break;
      case SettingsAction.restoreInvoices:
        _restoreInvoices(context);
        break;
      case SettingsAction.linkCustomers:
        _linkCustomers(context);
        break;
      case SettingsAction.ledgerImport:
        _importToLedger(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settings)),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: Text(S.of(context).product_management),
            subtitle: Text(S.of(context).product_management_desc),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductManagementScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SettingsActionsDropdown(
              showDebugOptions: kDebugMode,
              onSelected: (action) => _openAction(context, action),
            ),
          ),
          const Divider(),
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
                    '${S.of(context).could_not_save_appearance}: $error',
                    isError: true,
                  );
                }
              },
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
