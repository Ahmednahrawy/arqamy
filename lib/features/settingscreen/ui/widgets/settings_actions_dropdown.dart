import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// The actions grouped in one dropdown below Product management.
enum SettingsAction {
  backupInvoices,
  restoreInvoices,
  linkCustomers,
  ledgerImport,
}

extension SettingsActionLabel on SettingsAction {
  String label(S strings) {
    switch (this) {
      case SettingsAction.backupInvoices:
        return strings.backup_invoices;
      case SettingsAction.restoreInvoices:
        return strings.restore_invoices;
      case SettingsAction.linkCustomers:
        return strings.link_customers;
      case SettingsAction.ledgerImport:
        return strings.ledger_import;
    }
  }

  IconData get icon {
    switch (this) {
      case SettingsAction.backupInvoices:
        return Icons.backup_outlined;
      case SettingsAction.restoreInvoices:
        return Icons.restore;
      case SettingsAction.linkCustomers:
        return Icons.people_outline;
      case SettingsAction.ledgerImport:
        return Icons.account_balance_outlined;
    }
  }
}

/// Dropdown list of invoice actions shown in the settings screen.
///
/// Picking a choice calls [onSelected] and resets to the hint so the same
/// action can be picked again.
class SettingsActionsDropdown extends StatelessWidget {
  const SettingsActionsDropdown({
    super.key,
    required this.onSelected,
    this.showDebugOptions = false,
  });

  final ValueChanged<SettingsAction> onSelected;
  final bool showDebugOptions;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final actions = <SettingsAction>[
      SettingsAction.backupInvoices,
      SettingsAction.restoreInvoices,
      if (showDebugOptions) SettingsAction.linkCustomers,
      if (showDebugOptions) SettingsAction.ledgerImport,
    ];

    return DropdownButton<SettingsAction>(
      isExpanded: true,
      elevation: 8,
      borderRadius: BorderRadius.circular(15),
      dropdownColor: Theme.of(context).colorScheme.surface,
      icon: const Icon(Icons.arrow_drop_down),
      underline: const SizedBox.shrink(),
      hint: Row(
        children: [
          const Icon(Icons.inventory_2_outlined),
          const SizedBox(width: 12),
          Text(strings.invoice_actions),
        ],
      ),
      items: [
        for (final action in actions)
          DropdownMenuItem<SettingsAction>(
            value: action,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, size: 20),
                const SizedBox(width: 12),
                Text(action.label(strings)),
              ],
            ),
          ),
      ],
      onChanged: (action) {
        if (action != null) onSelected(action);
      },
    );
  }
}
