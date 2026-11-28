/// Editable inventory values for one product in the master product list.
///
/// Stock is keyed by product name so adding, renaming and deleting products in
/// product management keeps the inventory screen in sync.
class ProductStock {
  const ProductStock({this.quantity = 0, this.minOQ = 0});

  final int quantity;
  final int minOQ;

  /// The values used for a product that has never had its stock edited.
  static const empty = ProductStock();

  bool get isLow => quantity <= minOQ;

  Map<String, int> toJson() => {'quantity': quantity, 'minOQ': minOQ};

  /// Returns null when [value] is not a valid saved stock entry.
  static ProductStock? tryFromJson(Object? value) {
    if (value is! Map) return null;
    final quantity = value['quantity'];
    final minOQ = value['minOQ'];
    if (quantity is! int || quantity < 0) return null;
    if (minOQ is! int || minOQ < 0) return null;
    return ProductStock(quantity: quantity, minOQ: minOQ);
  }

  @override
  bool operator ==(Object other) =>
      other is ProductStock &&
      other.quantity == quantity &&
      other.minOQ == minOQ;

  @override
  int get hashCode => Object.hash(quantity, minOQ);
}
