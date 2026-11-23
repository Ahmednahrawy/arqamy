import 'dart:convert';

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice({String id = 'invoice-1', String? customerId}) {
  return Invoice(
    id: id,
    customerName: 'أحمد',
    products: [
      Product(
        name: 'قمح',
        weight: 10,
        packageWeight: 0,
        numberPackage: 0,
        price: 5,
      ),
    ],
    totalCost: 50,
    paid: 20,
    rest: 30,
    formattedDate: 'Nov 21, 2026',
    formattedTime: '10:30',
    invoiceAction: 'بيع',
    invoiceSerial: '1',
    customerId: customerId,
  );
}

String _backupWithCustomerId(Object? customerId) {
  final payload =
      jsonDecode(
            InvoiceBackup.encode(
              [_invoice()],
              exportedAt: DateTime.utc(2026, 11, 21),
            ),
          )
          as Map<String, dynamic>;
  ((payload['invoices'] as List).first as Map<String, dynamic>)['customerId'] =
      customerId;
  return jsonEncode(payload);
}

void main() {
  test('an invoice without a customer ID keeps its legacy JSON shape', () {
    expect(_invoice().toJson().containsKey('customerId'), isFalse);
  });

  test('legacy JSON without customerId loads with a null ID', () {
    expect(Invoice.fromJson(_invoice().toJson()).customerId, isNull);
  });

  test('a customer ID survives toJson and fromJson', () {
    final json = _invoice(customerId: 'customer-123').toJson();

    expect(json['customerId'], 'customer-123');
    expect(Invoice.fromJson(json).customerId, 'customer-123');
  });

  group('backup', () {
    test('keeps customer IDs next to legacy invoices', () {
      final original = [
        _invoice(customerId: 'customer-123'),
        _invoice(id: 'invoice-2'),
      ];

      final restored = InvoiceBackup.decode(
        InvoiceBackup.encode(original, exportedAt: DateTime.utc(2026, 11, 21)),
      );

      expect(restored.map((invoice) => invoice.customerId), [
        'customer-123',
        null,
      ]);
      expect(
        restored.map((invoice) => invoice.toJson()),
        original.map((invoice) => invoice.toJson()),
      );
    });

    test('accepts a backup where the customer ID is explicitly null', () {
      final restored = InvoiceBackup.decode(_backupWithCustomerId(null));

      expect(restored.single.customerId, isNull);
    });

    test('rejects a customer ID that is empty or not text', () {
      for (final bad in <Object>['', '  ', 5]) {
        expect(
          () => InvoiceBackup.decode(_backupWithCustomerId(bad)),
          throwsA(
            isA<InvoiceBackupFormatException>().having(
              (error) => error.message,
              'message',
              contains('customerId'),
            ),
          ),
        );
      }
    });
  });
}