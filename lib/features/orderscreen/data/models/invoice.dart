import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:uuid/uuid.dart';

class Invoice {
  static const Uuid _uuid = Uuid();

  static String generateId() => _uuid.v4();

  final String id;
  final String customerName;
  final List<Product> products;
  final double totalCost;
  final double paid;
  final double rest;
  final String formattedDate;
  final String formattedTime;
  final String? invoiceAction;
  final String invoiceSerial;

  Invoice({
    required this.id,
    required this.customerName,
    required this.products,
    required this.totalCost,
    required this.paid,
    required this.rest,
    required this.formattedDate,
    required this.formattedTime,
    this.invoiceAction,
    required this.invoiceSerial,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'products': products.map((product) => _productToMap(product)).toList(),
      'totalCost': totalCost,
      'paid': paid,
      'rest': rest,
      'formattedDate': formattedDate,
      'formattedTime': formattedTime,
      'invoiceAction': invoiceAction,
      'invoiceSerial': invoiceSerial,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      customerName: json['customerName'],
      products: (json['products'] as List).map((productMap) => _productFromMap(productMap)).toList(),
      totalCost: json['totalCost'],
      paid: json['paid'],
      rest: json['rest'],
      formattedDate: json['formattedDate'],
      formattedTime: json['formattedTime'],
      invoiceAction: json['invoiceAction'],
      invoiceSerial: json['invoiceSerial'],
    );
  }

  static Map<String, dynamic> _productToMap(Product product) {
    return {
      'name': product.name,
      'weight': product.weight,
      'packageWeight': product.packageWeight,
      'numberPackage': product.numberPackage,
      'price': product.price,
    };
  }

  static Product _productFromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      weight: map['weight'],
      packageWeight: map['packageWeight'],
      numberPackage: map['numberPackage'],
      price: map['price'],
    );
  }
}


// import 'package:arqamy/features/data/models/sales/customer.dart';
// import 'package:arqamy/features/data/models/supply/supply.dart';

// class Invoice {
//   final InvoiceInfo info;
//   final Supply supplier;
//   final Customer customer;
//   final List<InvoiceItem> items;

//   const Invoice({
//     required this.info,
//     required this.supplier,
//     required this.customer,
//     required this.items,
//   });
// }

// class InvoiceInfo {
//   final String description;
//   final String number;
//   final DateTime date;
//   final DateTime dueDate;

//   const InvoiceInfo({
//     required this.description,
//     required this.number,
//     required this.date,
//     required this.dueDate,
//   });
// }

// class InvoiceItem {
//   final String description;
//   final DateTime date;
//   final int quantity;
//   final double vat;
//   final double unitPrice;

//   const InvoiceItem({
//     required this.description,
//     required this.date,
//     required this.quantity,
//     required this.vat,
//     required this.unitPrice,
//   });
// }
