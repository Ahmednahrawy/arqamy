import 'package:arqamy/features/orderscreen/data/models/product_model.dart';

/// A column that can appear in an exported invoice table.
///
/// The same stable [key] is used by the PDF and Excel exports and by the
/// settings/backup files. Each export only offers the columns it renders.
enum InvoiceTableColumn {
  serial('serial'),
  date('date'),
  time('time'),
  customer('customer'),
  type('type'),
  product('product'),
  weight('weight'),
  packageWeight('packageWeight'),
  packageCount('packageCount'),
  netWeight('netWeight'),
  price('price'),
  total('total');

  const InvoiceTableColumn(this.key);

  /// Identifier stored in settings and backup files.
  final String key;

  /// Columns offered by the PDF product tables.
  ///
  /// Invoice-level fields such as the serial or customer are part of the PDF
  /// header, not of its product tables, so they are not offered here.
  static const pdfTableColumns = <InvoiceTableColumn>{
    product,
    weight,
    packageWeight,
    packageCount,
    netWeight,
    price,
    total,
  };

  static InvoiceTableColumn? tryParse(Object? raw) {
    if (raw is! String) return null;
    for (final column in values) {
      if (column.key == raw) return column;
    }
    return null;
  }
}

/// Which columns an export shows.
///
/// Hidden columns are stored (instead of visible ones) so a column added in a
/// later release stays visible for people who already saved their settings.
class InvoiceColumnVisibility {
  const InvoiceColumnVisibility({Set<InvoiceTableColumn> hidden = const {}})
    : _hidden = hidden;

  /// Every column visible; the default for new installations.
  static const allVisible = InvoiceColumnVisibility();

  final Set<InvoiceTableColumn> _hidden;

  Set<InvoiceTableColumn> get hiddenColumns => Set.unmodifiable(_hidden);

  bool isVisible(InvoiceTableColumn column) => !_hidden.contains(column);

  InvoiceColumnVisibility setVisible(InvoiceTableColumn column, bool visible) {
    final next = Set<InvoiceTableColumn>.of(_hidden);
    if (visible) {
      next.remove(column);
    } else {
      next.add(column);
    }
    return InvoiceColumnVisibility(hidden: next);
  }

  Map<String, Object?> toJson() => {
    'hidden': [
      for (final column in InvoiceTableColumn.values)
        if (_hidden.contains(column)) column.key,
    ],
  };

  /// Reads saved visibility. Anything missing or malformed means visible, so
  /// legacy settings keep every column.
  static InvoiceColumnVisibility fromJson(Object? raw) =>
      tryParseJson(raw) ?? allVisible;

  /// Strict parser for backup files: returns null when the stored value is not
  /// a valid visibility object.
  static InvoiceColumnVisibility? tryParseJson(Object? raw) {
    if (raw == null) return allVisible;
    if (raw is! Map) return null;
    final hidden = raw['hidden'];
    if (hidden is! List) return null;
    final columns = <InvoiceTableColumn>{};
    for (final value in hidden) {
      final column = InvoiceTableColumn.tryParse(value);
      if (column == null) return null;
      columns.add(column);
    }
    return InvoiceColumnVisibility(hidden: columns);
  }

  @override
  bool operator ==(Object other) {
    if (other is! InvoiceColumnVisibility) return false;
    if (other._hidden.length != _hidden.length) return false;
    return _hidden.containsAll(other._hidden);
  }

  @override
  int get hashCode => Object.hashAllUnordered(_hidden);

  @override
  String toString() => 'InvoiceColumnVisibility(hidden: $_hidden)';
}

/// The distinct package weights used by the products of one invoice.
class InvoicePackageWeights {
  const InvoicePackageWeights._(this._distinct);

  factory InvoicePackageWeights.fromProducts(Iterable<Product> products) {
    final distinct = <int, double>{};
    for (final product in products) {
      if (product.numberPackage <= 0) continue;
      if (!product.packageWeight.isFinite) continue;
      // Compare at gram precision so 2 and 2.0000001 count as the same weight.
      distinct[(product.packageWeight * 1000).round()] = product.packageWeight;
    }
    return InvoicePackageWeights._(List<double>.unmodifiable(distinct.values));
  }

  final List<double> _distinct;

  bool get hasPackages => _distinct.isNotEmpty;

  bool get hasSingleWeight => _distinct.length == 1;

  bool get hasMultipleWeights => _distinct.length > 1;

  /// The shared weight when every package has the same one.
  double? get singleWeight => hasSingleWeight ? _distinct.single : null;

  List<double> get distinctWeights => _distinct;
}

/// How package weight is rendered in an exported table.
enum PackageWeightDisplay {
  /// No package weight is shown (no packages, or the column is disabled).
  hidden,

  /// One shared weight: shown as a note under the table instead of a column.
  note,

  /// Different weights: shown as a per-row column.
  column,
}

PackageWeightDisplay resolvePackageWeightDisplay({
  required bool enabled,
  required InvoicePackageWeights weights,
}) {
  if (!enabled || !weights.hasPackages) return PackageWeightDisplay.hidden;
  return weights.hasMultipleWeights
      ? PackageWeightDisplay.column
      : PackageWeightDisplay.note;
}
