import 'dart:convert';

import 'package:arqamy/app/bootstrap/app_bootstrap.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads existing invoices before showing the application',
      (tester) async {
    final invoice = Invoice(
      id: 'invoice-1',
      customerName: 'Existing customer',
      products: const [],
      totalCost: 100,
      paid: 25,
      rest: 75,
      formattedDate: '2026-11-25',
      formattedTime: '10:00',
      invoiceAction: 'شراء',
      invoiceSerial: 'INV-001',
    );
    final provider = InvoiceProvider.withStorageWriter(
      (_) async => true,
      invoiceStorageReader: () async => jsonEncode([invoice.toJson()]),
    );

    await tester.pumpWidget(
      AppBootstrap(
        invoiceProvider: provider,
        child: const MaterialApp(home: Text('Application ready')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Application ready'), findsOneWidget);
    expect(provider.invoices, hasLength(1));
    expect(provider.invoices.single.id, 'invoice-1');
  });

  testWidgets('shows a retry screen when invoice storage cannot be read',
      (tester) async {
    var attempts = 0;
    final invoice = Invoice(
      id: 'invoice-2',
      customerName: 'Recovered customer',
      products: const [],
      totalCost: 50,
      paid: 0,
      rest: 50,
      formattedDate: '2026-11-25',
      formattedTime: '11:00',
      invoiceAction: 'بيع',
      invoiceSerial: 'INV-002',
    );
    final provider = InvoiceProvider.withStorageWriter(
      (_) async => true,
      invoiceStorageReader: () async {
        attempts++;
        if (attempts == 1) throw StateError('Storage unavailable');
        return jsonEncode([invoice.toJson()]);
      },
    );

    await tester.pumpWidget(
      AppBootstrap(
        invoiceProvider: provider,
        child: const MaterialApp(home: Text('Application ready')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Application ready'), findsNothing);
    expect(find.textContaining('Could not load saved invoices'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(provider.invoices, isEmpty);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Application ready'), findsOneWidget);
    expect(provider.invoices.single.id, 'invoice-2');
    expect(attempts, 2);
  });
}
