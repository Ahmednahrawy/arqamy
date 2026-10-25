import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfMyDataTable extends pw.StatelessWidget {
  final List<Product> products;
  // final double totalCost;
  final bool shouldShowPackageColumns;

  PdfMyDataTable({
    required this.products,
    // required this.totalCost,
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
        pw.TableRow(
          children: [
            _buildCell('المنتج'),
            _buildCell('الوزن-كجم'),
            if (shouldShowPackageColumns) _buildCell('وزن الفارغ-كجم'),
            if (shouldShowPackageColumns) _buildCell('عدد الفارغ'),
            if (shouldShowPackageColumns) _buildCell('صافي الوزن-كجم'),
            _buildCell('السعر - جنيه'),
            _buildCell('إجمالي - جنيه'),
          ],
        ),
        for (var product in products)
          pw.TableRow(
            children: [
              _buildCell(product.name.toString()),
              _buildCell('${product.weight}'),
              if (shouldShowPackageColumns)
                _buildCell(product.packageWeight.toStringAsFixed(2)),
              if (shouldShowPackageColumns)
                _buildCell(product.numberPackage.toString()),
              if (shouldShowPackageColumns)
                _buildCell(product.netWeight.toString()),
              _buildCell(product.price.toStringAsFixed(2)),
              _buildCell(product.totalPrice.toString()),
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
