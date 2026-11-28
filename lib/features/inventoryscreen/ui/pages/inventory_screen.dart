import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/data/models/inventory_item.dart';
import 'package:arqamy/features/data/models/product_stock.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Inventory screen backed by the same product list used in product management.
///
/// Products, their default cost and their stock values all come from
/// [InvoiceProvider], so edits made in product management show up here
/// immediately. Quantity and minimum stock are editable per product and saved
/// alongside the master products.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InvoiceProvider>().loadMasterProducts();
    });
  }

  Future<void> _showStockDialog(
    BuildContext context,
    InvoiceProvider provider,
    String productName,
  ) async {
    final updated = await showDialog<ProductStock>(
      context: context,
      builder: (_) => _StockEditDialog(
        productName: productName,
        stock: provider.stockForProduct(productName),
      ),
    );
    if (updated == null || !mounted) return;

    await provider.setMasterProductStock(
      productName,
      quantity: updated.quantity,
      minOQ: updated.minOQ,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.inventory)),
      body: SafeArea(
        child: Consumer<InvoiceProvider>(
          builder: (context, provider, child) {
            final items = [
              for (final productName in provider.masterProductList)
                InventoryItem(
                  provider.stockForProduct(productName).minOQ,
                  name: productName,
                  quantity: provider.stockForProduct(productName).quantity,
                  cost:
                      provider.defaultProductPrice(
                        productName,
                        InvoiceAction.purchase,
                      ) ??
                      0,
                ),
            ];
            final totalQuantity = items.fold<int>(
              0,
              (total, item) => total + item.quantity,
            );
            final lowStockCount = items
                .where((item) => item.quantity <= item.minOQ)
                .length;

            return ListView(
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
                    _InventoryItemCard(
                      item: item,
                      onEdit: () =>
                          _showStockDialog(context, provider, item.name),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StockEditDialog extends StatefulWidget {
  const _StockEditDialog({required this.productName, required this.stock});

  final String productName;
  final ProductStock stock;

  @override
  State<_StockEditDialog> createState() => _StockEditDialogState();
}

class _StockEditDialogState extends State<_StockEditDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _minimumController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: '${widget.stock.quantity}',
    );
    _minimumController = TextEditingController(text: '${widget.stock.minOQ}');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  void _save() {
    final strings = S.of(context);
    final quantity = int.tryParse(_quantityController.text.trim());
    final minimum = int.tryParse(_minimumController.text.trim());
    if (quantity == null || minimum == null || quantity < 0 || minimum < 0) {
      showAppSnackBar(context, strings.invalidInteger, isError: true);
      return;
    }
    Navigator.pop(context, ProductStock(quantity: quantity, minOQ: minimum));
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return AlertDialog(
      title: Text('${strings.edit} — ${widget.productName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('inventory-quantity-field'),
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: strings.quantity,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('inventory-minimum-field'),
              controller: _minimumController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: strings.inventory_minimum,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(strings.save)),
      ],
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
  const _InventoryItemCard({required this.item, required this.onEdit});

  final InventoryItem item;
  final VoidCallback onEdit;

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            else
              Text(
                '${item.quantity} ${strings.inventory_total_quantity}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            IconButton(
              key: ValueKey('edit-stock-${item.name}'),
              icon: const Icon(Icons.edit_outlined),
              tooltip: strings.edit,
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
