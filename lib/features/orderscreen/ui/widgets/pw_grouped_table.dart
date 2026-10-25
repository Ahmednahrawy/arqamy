import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGroupedDataTable extends pw.StatelessWidget {
  final List<Product> groupedProducts;
  final bool shouldShowPackageColumns;

  PdfGroupedDataTable({
    required this.groupedProducts,
    required this.shouldShowPackageColumns,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Table(
      border: pw.TableBorder.symmetric(
        outside: const pw.BorderSide(width: 2),
        inside: const pw.BorderSide(width: 1),
      ),
      children: [
        // Header
        pw.TableRow(
          children: [
            _buildCell('المنتج'),
            _buildCell('الوزن-كجم'),
            if (shouldShowPackageColumns) _buildCell('وزن الفارغ-كجم'),
            if (shouldShowPackageColumns) _buildCell('عدد الفارغ'),
            if (shouldShowPackageColumns) _buildCell('صافي الوزن '),
            _buildCell('السعر'),
            _buildCell('إجمالي السعر'),
          ],
        ),
        // Rows
        for (var product in groupedProducts)
          pw.TableRow(
            children: [
              _buildCell(product.name),
              _buildCell('${product.weight}'),
              if (shouldShowPackageColumns)
                _buildCell(product.packageWeight.toStringAsFixed(2)),
              if (shouldShowPackageColumns)
                _buildCell(product.numberPackage.toString()),
              if (shouldShowPackageColumns)
                _buildCell(product.netWeight.toStringAsFixed(2)),
              _buildCell(product.price.toStringAsFixed(2)),
              _buildCell(product.totalPrice.toStringAsFixed(2)),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: pw.Text(
        text,
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 17),
        overflow: pw.TextOverflow.visible,
      ),
    );
  }
}
