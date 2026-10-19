import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDataTable extends StatelessWidget {
  const MyDataTable({Key? key, this.isInModal = false}) : super(key: key);

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
  void _confirmDelete(BuildContext context, int index) {
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
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
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
    child: DataTable(
      columns: buildDetailedColumns(showPackageColumns),
      rows: products.map((product) {
        final index = products.indexOf(product);
        final netWeight =
            product.weight - (product.packageWeight * product.numberPackage);
        final totalPrice = netWeight * product.price;
        // Build cells conditionally
        final cells = <DataCell>[
          DataCell(
            Center(
              child: IconButton(
                onPressed: () => _confirmDelete(context, index),
                icon: const Icon(Icons.delete, color: Colors.red),
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
      dataRowColor: WidgetStateProperty.all<Color>(
        const Color.fromARGB(255, 232, 217, 216),
      ),
      headingTextStyle: const TextStyle(),
      border: const TableBorder(
        bottom: BorderSide(width: 1),
        top: BorderSide(width: 1),
        verticalInside: BorderSide(width: 1),
      ),
      horizontalMargin: 10,
      columnSpacing: 5,
      showCheckboxColumn: false,
    ),
  );
}

Widget _buildTotalsTable(
    List<Product> products, BuildContext context, bool showPackageColumns) {
  return DataTable(
    columns: [
      _buildDataColumn('المنتج'),
      // _buildDataColumn('إجمالي الوزن'),
      // _buildDataColumn('عدد العبوات'),
      _buildDataColumn('صافي الوزن'),
      _buildDataColumn('السعر'),
      _buildDataColumn('الإجمالي'),
    ],
    rows: products.map((product) {
      final netWeight =
          product.weight - (product.packageWeight * product.numberPackage);
      final totalPrice = netWeight * product.price;
      return DataRow(cells: [
        _buildDataCell((product.name)),
        // _buildDataCell(('${product.weight.toStringAsFixed(2)} kg')),
        // _buildDataCell(('${product.numberPackage}')),
        _buildDataCell(('${netWeight.toStringAsFixed(2)} kg')),
        _buildDataCell(('${product.price.toStringAsFixed(2)} L.E')),
        _buildDataCell(('${totalPrice.toStringAsFixed(2)} L.E')),
      ]);
    }).toList(),
    dataRowColor: WidgetStateProperty.all<Color>(
      const Color.fromARGB(255, 232, 217, 216),
    ),
    headingTextStyle: const TextStyle(),
    border: const TableBorder(
      bottom: BorderSide(width: 1),
      top: BorderSide(width: 1),
      verticalInside: BorderSide(width: 1),
    ),
    horizontalMargin: 10,
    columnSpacing: 5,
    showCheckboxColumn: false,
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
