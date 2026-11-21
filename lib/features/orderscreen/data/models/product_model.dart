import 'package:arqamy/core/helpers/money.dart';

// redundant should be removed soon
class Product {
  final String name;
  final double weight;
  final double packageWeight;
  final double price;
  final int numberPackage;

  /// Set only on merged summary rows: the sum of the already-rounded totals
  /// of the rows that were merged, so the summary adds up to the invoice total.
  final Money? lineTotalOverride;
  // final String action;
  double get netWeight => weight - (packageWeight * numberPackage);

  /// Line total rounded to 0.01, half away from zero.
  Money get lineTotal =>
      lineTotalOverride ?? Money.fromDouble(netWeight * price);
  double get totalPrice => lineTotal.toDouble();

  Product({
    required this.name,
    required this.weight,
    required this.packageWeight,
    required this.numberPackage,
    required this.price,
    this.lineTotalOverride,
    // required this.action,
  });
}
