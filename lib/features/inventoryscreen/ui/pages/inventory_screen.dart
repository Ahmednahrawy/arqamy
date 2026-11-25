import 'package:arqamy/features/data/models/inventory_item.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// UI-only inventory screen.
///
/// The items below are static preview data; no persistence or business logic
/// is wired up yet.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  static final List<InventoryItem> _previewItems = [
    InventoryItem(8, name: 'Rice', quantity: 64, cost: 10),
    InventoryItem(4, name: 'Sugar', quantity: 3, cost: 14),
    InventoryItem(6, name: 'Tea', quantity: 18, cost: 8),
    InventoryItem(10, name: 'Coffee', quantity: 24, cost: 35),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final items = _previewItems;
    final totalQuantity = items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final lowStockCount = items
        .where((item) => item.quantity <= item.minOQ)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(strings.inventory)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.inventory_2_outlined,
                    label: strings.inventory_total_items,
                    value: '${items.length}',
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning_amber_outlined,
                    label: strings.inventory_low_stock,
                    value: '$lowStockCount',
                    color: colors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.numbers_outlined,
                    label: strings.inventory_total_quantity,
                    value: '$totalQuantity',
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              strings.inventory_items,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 56,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.inventory_empty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final item in items) ...[
                _InventoryItemCard(item: item),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLow = item.quantity <= item.minOQ;

    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Icon(
            Icons.inventory_2_outlined,
            color: colors.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(item.name),
        subtitle: Text(
          '${strings.quantity}: ${item.quantity}  •  '
          '${strings.price_egp}: ${item.cost.toStringAsFixed(2)}  •  '
          '${strings.inventory_minimum}: ${item.minOQ}',
        ),
        trailing: isLow
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  strings.inventory_low_stock,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              )
            : Text(
                '${item.quantity} ${strings.inventory_total_quantity}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}
