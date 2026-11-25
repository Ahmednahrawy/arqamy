import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/helpers/invoice_action_l10n.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/generated/l10n.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadMasterProducts();
    });
  }

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  Widget _buildSearchField(S strings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        key: const ValueKey('product-management-search'),
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: strings.productSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  key: const ValueKey('clear-product-search'),
                  tooltip: strings.clearInvoiceSearch,
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                ),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _showAddDialog() {
    _addController.clear();
    final messenger = ScaffoldMessenger.of(context);
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.add_new_product),
        content: TextField(
          controller: _addController,
          decoration: InputDecoration(
            hintText: strings.productName,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_addController.text.trim().isNotEmpty) {
                try {
                  await context.read<InvoiceProvider>().addMasterProduct(
                    _addController.text,
                  );
                  if (!mounted || !dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  showAppSnackBarOn(
                    messenger,
                    strings.product_added_successfully,
                  );
                } catch (error) {
                  if (!mounted || !messenger.mounted) return;
                  showAppSnackBarOn(
                    messenger,
                    '${strings.could_not_add_product}: $error',
                    isError: true,
                  );
                }
              }
            },
            child: Text(strings.addProduct),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index, String currentName) {
    _editController.text = currentName;
    final messenger = ScaffoldMessenger.of(context);
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.edit_product),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(
            hintText: strings.productName,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editController.text.trim().isNotEmpty) {
                try {
                  await context.read<InvoiceProvider>().editMasterProduct(
                    index,
                    _editController.text,
                  );
                  if (!mounted || !dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  showAppSnackBarOn(
                    messenger,
                    strings.product_updated_successfully,
                  );
                } catch (error) {
                  if (!mounted || !messenger.mounted) return;
                  showAppSnackBarOn(
                    messenger,
                    '${strings.could_not_update_product}: $error',
                    isError: true,
                  );
                }
              }
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index, String productName) {
    final messenger = ScaffoldMessenger.of(context);
    final colors = Theme.of(context).colorScheme;
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.delete_product),
        content: Text('${strings.confirm_delete_product}\n"$productName"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<InvoiceProvider>().deleteMasterProduct(
                  index,
                );
                if (!mounted || !dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                showAppSnackBarOn(
                  messenger,
                  strings.product_deleted_successfully,
                );
              } catch (error) {
                if (!mounted || !messenger.mounted) return;
                showAppSnackBarOn(
                  messenger,
                  '${strings.could_not_delete_product}: $error',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.product_management),
        actions: [
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            tooltip: strings.addProduct,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<InvoiceProvider>(
          builder: (context, provider, child) {
            final products = provider.masterProductList;
            final query = _searchQuery.trim().toLowerCase();
            final visibleProducts = query.isEmpty
                ? products
                : products
                      .where((product) => product.toLowerCase().contains(query))
                      .toList();

            Widget buildItem(int index) {
              final product = visibleProducts[index];
              // Edit/delete operate on the provider's full list, not the
              // filtered view, so look up the real index by product name.
              final providerIndex = products.indexOf(product);
              return Card(
                key: ValueKey(product),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: query.isEmpty
                      ? Icon(Icons.drag_handle, color: colors.onSurfaceVariant)
                      : const SizedBox(width: 24),
                  title: Text(product),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Row(
                      children: [
                        for (final action in InvoiceAction.values) ...[
                          Expanded(
                            child: _ProductPriceField(
                              productName: product,
                              action: action,
                              label: InvoiceActionL10n.labelFor(
                                action,
                                strings,
                              ),
                              price: provider
                                  .masterProductPrices[product]?[action],
                              onChanged: (value) {
                                provider.setMasterProductPrice(
                                  product,
                                  action,
                                  value,
                                );
                              },
                            ),
                          ),
                          if (action != InvoiceAction.values.last)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            _showEditDialog(providerIndex, product),
                        icon: Icon(Icons.edit, color: colors.primary),
                        tooltip: strings.edit,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            _showDeleteConfirmation(providerIndex, product),
                        icon: Icon(Icons.delete, color: colors.error),
                        tooltip: strings.delete,
                      ),
                    ],
                  ),
                ),
              );
            }

            late final Widget content;
            if (products.isEmpty) {
              content = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 64,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.no_products,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.tap_to_add_product,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            } else if (visibleProducts.isEmpty) {
              content = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 56,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.noProductsMatchSearch,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            } else if (query.isEmpty) {
              content = ReorderableListView.builder(
                itemCount: visibleProducts.length,
                onReorderItem: (oldIndex, newIndex) async {
                  // onReorderItem gives the item's final position, but the
                  // provider expects the raw index (it adjusts itself).
                  final rawNewIndex = newIndex > oldIndex
                      ? newIndex + 1
                      : newIndex;
                  await provider.reorderMasterProducts(oldIndex, rawNewIndex);
                },
                itemBuilder: (context, index) => buildItem(index),
              );
            } else {
              content = ListView.builder(
                itemCount: visibleProducts.length,
                itemBuilder: (context, index) => buildItem(index),
              );
            }

            return Column(
              children: [
                _buildSearchField(strings),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: strings.addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductPriceField extends StatefulWidget {
  const _ProductPriceField({
    required this.productName,
    required this.action,
    required this.label,
    required this.price,
    required this.onChanged,
  });

  final String productName;
  final InvoiceAction action;
  final String label;
  final double? price;
  final ValueChanged<double?> onChanged;

  @override
  State<_ProductPriceField> createState() => _ProductPriceFieldState();
}

class _ProductPriceFieldState extends State<_ProductPriceField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.price == null ? '' : widget.price!.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelSmall,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Tooltip(
          message: strings.default_price_optional,
          child: TextField(
            key: ValueKey(
              'product-default-price-${widget.productName}-${widget.action.name}',
            ),
            controller: _controller,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: strings.price,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              final text = value.trim();
              if (text.isEmpty) {
                widget.onChanged(null);
                return;
              }
              final parsed = double.tryParse(text);
              if (parsed != null && parsed.isFinite && parsed >= 0) {
                widget.onChanged(parsed);
              }
            },
          ),
        ),
      ],
    );
  }
}
