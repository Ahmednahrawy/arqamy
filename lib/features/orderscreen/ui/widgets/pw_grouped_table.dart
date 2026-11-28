import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/invoice_export_columns.dart';
import 'package:arqamy/core/helpers/pdf_labels.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGroupedDataTable extends pw.StatelessWidget {
  final List<Product> groupedProducts;
  final InvoiceColumnVisibility columns;
  final PackageWeightDisplay packageWeightDisplay;
  final bool hasPackageProducts;
  final PdfLabels labels;

  PdfGroupedDataTable({
    required this.groupedProducts,
    required this.columns,
    required this.packageWeightDisplay,
    required this.hasPackageProducts,
    required this.labels,
  });

  @override
  pw.Widget build(pw.Context context) {
    final showProduct = columns.isVisible(InvoiceTableColumn.product);
    final showWeight = columns.isVisible(InvoiceTableColumn.weight);
    final showPackageWeight =
        hasPackageProducts &&
        columns.isVisible(InvoiceTableColumn.packageWeight) &&
        packageWeightDisplay == PackageWeightDisplay.column;
    final showPackageCount =
        hasPackageProducts &&
        columns.isVisible(InvoiceTableColumn.packageCount);
    final showNetWeight =
        hasPackageProducts && columns.isVisible(InvoiceTableColumn.netWeight);
    final showPrice = columns.isVisible(InvoiceTableColumn.price);
    final showTotal = columns.isVisible(InvoiceTableColumn.total);

    if (!(showProduct ||
        showWeight ||
        showPackageWeight ||
        showPackageCount ||
        showNetWeight ||
        showPrice ||
        showTotal)) {
      return pw.SizedBox();
    }

    final headerCells = <pw.Widget>[
      if (showProduct) _buildCell(labels.product),
      if (showWeight) _buildCell(labels.weightKg),
      if (showPackageWeight) _buildCell(labels.packageWeightKg),
      if (showPackageCount) _buildCell(labels.packageCount),
      if (showNetWeight) _buildCell(labels.netWeightKg),
      if (showPrice) _buildCell(labels.priceEgp),
      if (showTotal) _buildCell(labels.totalPrice),
    ];

    return pw.Table(
      border: pw.TableBorder.symmetric(
        outside: const pw.BorderSide(width: 2),
        inside: const pw.BorderSide(width: 1),
      ),
      children: [
        // Header
        pw.TableRow(children: _rowCells(headerCells)),
        // Rows
        for (var product in groupedProducts)
          pw.TableRow(
            children: _rowCells([
              if (showProduct) _buildCell(product.name),
              if (showWeight) _buildCell(AppFormatters.number(product.weight)),
              if (showPackageWeight)
                _buildCell(AppFormatters.number(product.packageWeight)),
              if (showPackageCount)
                _buildCell(product.numberPackage.toString()),
              if (showNetWeight)
                _buildCell(AppFormatters.number(product.netWeight)),
              if (showPrice) _buildCell(AppFormatters.number(product.price)),
              if (showTotal)
                _buildCell(AppFormatters.number(product.totalPrice)),
            ]),
          ),
      ],
    );
  }

  List<pw.Widget> _rowCells(List<pw.Widget> cells) =>
      labels.isRtl ? cells.reversed.toList() : cells;

  pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: pw.Text(
        text,
        textDirection:
            labels.isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 17),
        overflow: pw.TextOverflow.visible,
      ),
    );
  }
}
