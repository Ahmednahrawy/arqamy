import 'package:arqamy/core/helpers/formatters.dart';
import 'package:arqamy/core/helpers/pdf_labels.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfMyDataTable extends pw.StatelessWidget {
  final List<Product> products;
  final bool shouldShowPackageColumns;
  final PdfLabels labels;

  PdfMyDataTable({
    required this.products,
    required this.shouldShowPackageColumns,
    required this.labels,
  });

  @override
  pw.Widget build(pw.Context context) {
    final headerCells = <pw.Widget>[
      _buildCell(labels.product),
      _buildCell(labels.weightKg),
      if (shouldShowPackageColumns) _buildCell(labels.packageWeightKg),
      if (shouldShowPackageColumns) _buildCell(labels.packageCount),
      if (shouldShowPackageColumns) _buildCell(labels.netWeightKg),
      _buildCell(labels.priceEgp),
      _buildCell(labels.totalEgp),
    ];

    return pw.Table(
      border: pw.TableBorder.symmetric(
        outside: const pw.BorderSide(width: 2),
        inside: const pw.BorderSide(width: 1),
      ),
      children: [
        pw.TableRow(
          children: labels.isRtl ? headerCells.reversed.toList() : headerCells,
        ),
        for (var product in products)
          pw.TableRow(
            children: _rowCells([
              _buildCell(product.name.toString()),
              _buildCell(AppFormatters.number(product.weight)),
              if (shouldShowPackageColumns)
                _buildCell(
                  AppFormatters.number(product.packageWeight),
                ),
              if (shouldShowPackageColumns)
                _buildCell(product.numberPackage.toString()),
              if (shouldShowPackageColumns)
                _buildCell(AppFormatters.number(product.netWeight)),
              _buildCell(AppFormatters.number(product.price)),
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
