import 'dart:convert';

import 'package:arqamy/core/helpers/invoice_backup.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(String id, {String? action = 'بيع', String serial = '7'}) {
  return Invoice(
    id: id,
    customerName: 'أحمد',
    products: [
      Product(
        name: 'قمح',
        weight: 12.345,
        packageWeight: 0.5,
        numberPackage: 2,
        price: 7.25,
      ),
    ],
    totalCost: 82.25,
    paid: 50,
    rest: 32.25,
    formattedDate: 'Nov 21, 2026',
    formattedTime: '10:30',
    invoiceAction: action,
    invoiceSerial: serial,
  );
}

String _encode(List<Invoice> invoices) =>
    InvoiceBackup.encode(invoices, exportedAt: DateTime.utc(2026, 11, 21, 12));

Map<String, dynamic> _payload([List<Invoice>? invoices]) =>
    jsonDecode(_encode(invoices ?? [_invoice('a'), _invoice('b')]))
        as Map<String, dynamic>;

Map<String, dynamic> _firstInvoice(Map<String, dynamic> payload) =>
    (payload['invoices'] as List).first as Map<String, dynamic>;

Map<String, dynamic> _firstProduct(Map<String, dynamic> payload) =>
    (_firstInvoice(payload)['products'] as List).first as Map<String, dynamic>;

void _expectRejected(Map<String, dynamic> payload, String messagePart) {
  expect(
    () => InvoiceBackup.decode(jsonEncode(payload)),
    throwsA(
      isA<InvoiceBackupFormatException>().having(
        (error) => error.message,
        'message',
        contains(messagePart),
      ),
    ),
  );
}

void main() {
  test('round trip keeps every field and the order', () {
    final original = [
      _invoice('b', serial: '2'),
      _invoice('a', action: null, serial: '1'),
    ];

    final restored = InvoiceBackup.decode(_encode(original));

    expect(
      restored.map((invoice) => invoice.toJson()),
      original.map((invoice) => invoice.toJson()),
    );
  });

  test('an empty backup is valid', () {
    expect(InvoiceBackup.decode(_encode([])), isEmpty);
  });

  test('the header describes the backup', () {
    final payload = _payload();

    expect(payload['format'], 'arqamy-invoices');
    expect(payload['version'], 1);
    expect(payload['invoiceCount'], 2);
    expect(payload['exportedAt'], '2026-11-21T12:00:00.000Z');
  });

  test('whole numbers are accepted where decimals are expected', () {
    final payload = _payload();
    _firstInvoice(payload)['totalCost'] = 100;
    _firstProduct(payload)['price'] = 5;

    final restored = InvoiceBackup.decode(jsonEncode(payload));

    expect(restored.first.totalCost, 100.0);
    expect(restored.first.products.first.price, 5.0);
  });

  group('rejects a bad backup as a whole', () {
    test('text that is not JSON', () {
      expect(
        () => InvoiceBackup.decode('not json'),
        throwsA(isA<InvoiceBackupFormatException>()),
      );
    });

    test('JSON that is not an object', () {
      expect(
        () => InvoiceBackup.decode('[]'),
        throwsA(isA<InvoiceBackupFormatException>()),
      );
    });

    test('another format', () {
      _expectRejected(
        _payload()..['format'] = 'other',
        'not an Arqamy invoice backup',
      );
    });

    test('a newer version', () {
      _expectRejected(_payload()..['version'] = 2, 'newer version');
    });

    test('a missing invoice list', () {
      _expectRejected(_payload()..remove('invoices'), 'no invoice list');
    });

    test('an invoice count that does not match', () {
      _expectRejected(_payload()..['invoiceCount'] = 3, 'incomplete');
    });

    test('duplicate invoice ids', () {
      _expectRejected(
        _payload([_invoice('a'), _invoice('a')]),
        'Duplicate invoice id',
      );
    });

    test('a missing id', () {
      final payload = _payload();
      _firstInvoice(payload).remove('id');
      _expectRejected(payload, 'Invoice 1 is invalid');
    });

    test('text where a number is expected', () {
      final payload = _payload();
      _firstInvoice(payload)['paid'] = '50';
      _expectRejected(payload, 'paid');
    });

    test('an amount that is too large', () {
      final payload = _payload();
      _firstInvoice(payload)['totalCost'] = 1e15;
      _expectRejected(payload, 'totalCost');
    });

    test('a fractional package count', () {
      final payload = _payload();
      _firstProduct(payload)['numberPackage'] = 1.5;
      _expectRejected(payload, 'numberPackage');
    });

    test('an invoice type that is not text', () {
      final payload = _payload();
      _firstInvoice(payload)['invoiceAction'] = 5;
      _expectRejected(payload, 'invoiceAction');
    });
  });
}