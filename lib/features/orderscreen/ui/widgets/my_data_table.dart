import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:arqamy/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class MyDataTable extends StatelessWidget {
  const MyDataTable({super.key, this.isInModal = false});

  final bool isInModal;

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final shouldShowPackageColumns = provider.shouldShowPackageColumns;
        // ✅ Case 1: on OrderScreen (only totals)
        if (!isInModal) {
          return _buildTotalsTable(
              provider.groupedProducts, context, shouldShowPackageColumns);
        }
        if (provider.hasIdenticalProducts) {
          // ✅ Case 2: inside Modal (two tables: detailed + totals)
          final strings = S.of(context);
          return Column(
            children: [
              Text(strings.weight_details,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailedTable(
                  provider.products, context, shouldShowPackageColumns),
              const SizedBox(height: 16),
              Text(strings.totals,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildTotalsTable(
                  provider.groupedProducts, context, shouldShowPackageColumns),
            ],
          );
        } else {
          // Show only totals table (no identical products)
          return Column(
            children: [
              Text(S.of(context).product_details,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailedTable(
                  provider.products, context, shouldShowPackageColumns),
            ],
          );
        }
      },
    );
  }
}

Widget _buildDetailedTable(
    List<Product> products, BuildContext context, bool showPackageColumns) {
  final colors = Theme.of(context).colorScheme;
  final strings = S.of(context);
  void confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirm_delete),
        content: Text(strings.confirm_delete_product),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<InvoiceProvider>().removeProductAt(index);
              Navigator.pop(context);
            },
            child: Text(strings.delete, style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }

  // Build columns conditionally
  List<DataColumn> buildDetailedColumns(bool showPackageColumns) {
    final columns = <DataColumn>[
      _buildDataColumn(strings.delete),
      _buildDataColumn(strings.product),
      _buildDataColumn(strings.weight),
    ];

    if (showPackageColumns) {
      columns.addAll([
        _buildDataColumn(strings.packageCount),
        _buildDataColumn(strings.net_weight),
      ]);
    }

    columns.addAll([
      _buildDataColumn(strings.price),
      _buildDataColumn(strings.total),
    ]);

    return columns;
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: DataTable(
        columns: buildDetailedColumns(showPackageColumns),
        rows: products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final netWeight = product.netWeight;
          final totalPrice = product.totalPrice;
          // Build cells conditionally
          final cells = <DataCell>[
            DataCell(
              Center(
                child: IconButton(
                  onPressed: () => confirmDelete(context, index),
                  icon: Icon(Icons.delete, color: colors.error),
                ),
              ),
            ),
            _buildDataCell((product.name)),
            _buildDataCell(AppFormatters.weight(product.weight, strings)),
          ];

          if (showPackageColumns) {
            cells.addAll([
              _buildDataCell(('${product.numberPackage}')),
              _buildDataCell(AppFormatters.weight(netWeight, strings)),
            ]);
          }

          cells.addAll([
            _buildDataCell(AppFormatters.currency(product.price, strings)),
            _buildDataCell(AppFormatters.currency(totalPrice, strings)),
          ]);

          return DataRow(cells: cells);
        }).toList(),
        dataRowColor: WidgetStatePropertyAll(colors.surfaceContainerHighest),
        headingTextStyle: Theme.of(context).textTheme.labelLarge,
        border: TableBorder(
          bottom: BorderSide(width: 1, color: colors.outlineVariant),
          top: BorderSide(width: 1, color: colors.outlineVariant),
          verticalInside: BorderSide(width: 1, color: colors.outlineVariant),
        ),
        horizontalMargin: 10,
        columnSpacing: 5,
        showCheckboxColumn: false,
      ),
    ),
  );
}

Widget _buildTotalsTable(
    List<Product> products, BuildContext context, bool showPackageColumns) {
  final strings = S.of(context);
  return LayoutBuilder(
    builder: (context, constraints) {
      final colors = Theme.of(context).colorScheme;
      final availableWidth = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final minWidth =
          availableWidth > 24 ? availableWidth - 24 : availableWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DataTable(
              columns: [
                _buildDataColumn(strings.product),
                _buildDataColumn(strings.net_weight),
                _buildDataColumn(strings.price),
                _buildDataColumn(strings.total_amount),
              ],
              rows: products.map((product) {
                final netWeight = product.netWeight;
                final totalPrice = product.totalPrice;
                return DataRow(cells: [
                  _buildDataCell(product.name),
                  _buildDataCell(AppFormatters.weight(netWeight, strings)),
                  _buildDataCell(AppFormatters.currency(product.price, strings)),
                  _buildDataCell(AppFormatters.currency(totalPrice, strings)),
                ]);
              }).toList(),
              dataRowColor:
                  WidgetStatePropertyAll(colors.surfaceContainerHighest),
              headingTextStyle: Theme.of(context).textTheme.labelLarge,
              border: TableBorder(
                bottom: BorderSide(width: 1, color: colors.outlineVariant),
                top: BorderSide(width: 1, color: colors.outlineVariant),
                verticalInside:
                    BorderSide(width: 1, color: colors.outlineVariant),
              ),
              // columnSpacing: 5,
              horizontalMargin: 8,
              columnSpacing: 4,
              showCheckboxColumn: false,
            ),
          ),
        ),
      );
    },
  );
}

DataCell _buildDataCell(String text) {
  return DataCell(
    Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

DataColumn _buildDataColumn(String text) {
  return DataColumn(
    label: Text(text, textAlign: TextAlign.center),
  );
}
