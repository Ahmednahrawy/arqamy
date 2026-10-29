import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
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
          return Column(
            children: [
              const Text("تفاصيل الأوزان",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDetailedTable(
                  provider.products, context, shouldShowPackageColumns),
              const SizedBox(height: 16),
              const Text("الإجماليات",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTotalsTable(
                  provider.groupedProducts, context, shouldShowPackageColumns),
            ],
          );
        } else {
          // Show only totals table (no identical products)
          return Column(
            children: [
              const Text("تفاصيل المنتجات",
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
  void confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذا المنتج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              context.read<InvoiceProvider>().removeProductAt(index);
              Navigator.pop(context);
            },
            child: Text("حذف", style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }

  // Build columns conditionally
  List<DataColumn> buildDetailedColumns(bool showPackageColumns) {
    final columns = <DataColumn>[
      _buildDataColumn('حذف'),
      _buildDataColumn('المنتج'),
      _buildDataColumn('الوزن'),
    ];

    if (showPackageColumns) {
      columns.addAll([
        _buildDataColumn('عدد العبوات'),
        _buildDataColumn('صافي الوزن'),
      ]);
    }

    columns.addAll([
      _buildDataColumn('السعر'),
      _buildDataColumn('إجمالي'),
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
            _buildDataCell(('${product.weight.toStringAsFixed(2)} kg')),
          ];

          if (showPackageColumns) {
            cells.addAll([
              _buildDataCell(('${product.numberPackage}')),
              _buildDataCell(('${netWeight.toStringAsFixed(2)} kg')),
            ]);
          }

          cells.addAll([
            _buildDataCell(('${product.price.toStringAsFixed(2)} L.E')),
            _buildDataCell(('${totalPrice.toStringAsFixed(2)} L.E')),
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
                _buildDataColumn('المنتج'),
                _buildDataColumn('صافي الوزن'),
                _buildDataColumn('السعر'),
                _buildDataColumn('الإجمالي'),
              ],
              rows: products.map((product) {
                final netWeight = product.netWeight;
                final totalPrice = product.totalPrice;
                return DataRow(cells: [
                  _buildDataCell(product.name),
                  _buildDataCell('${netWeight.toStringAsFixed(2)} kg'),
                  _buildDataCell('${product.price.toStringAsFixed(2)} L.E'),
                  _buildDataCell('${totalPrice.toStringAsFixed(2)} L.E'),
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
