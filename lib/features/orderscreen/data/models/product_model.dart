// redundant should be removed soon
class Product {
  final String name;
  final double weight;
  final double packageWeight;
  final double price; 
  final int numberPackage;
  // final String action;
  double get netWeight => weight - (packageWeight * numberPackage);
  double get totalPrice => netWeight * price;

  Product({
    required this.name,
    required this.weight,
    required this.packageWeight,
    required this.numberPackage,
    required this.price,
    // required this.action,
  });
}