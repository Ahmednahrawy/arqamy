import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/helpers/invoice_action_l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stored values never change', () {
    expect(InvoiceAction.purchase.storedValue, 'شراء');
    expect(InvoiceAction.sale.storedValue, 'بيع');
    expect(InvoiceAction.storage.storedValue, 'تخزين');
  });

  test('storedValues keeps the selector order used today', () {
    expect(InvoiceAction.storedValues, ['شراء', 'بيع', 'تخزين']);
    expect(InvoiceAction.storedValues, InvoiceActionL10n.actions);
  });

  test('tryParse ignores tatweel and surrounding spaces', () {
    expect(InvoiceAction.tryParse('بي\u0640ع'), InvoiceAction.sale);
    expect(InvoiceAction.tryParse('  شراء '), InvoiceAction.purchase);
    expect(InvoiceAction.tryParse('تخزين'), InvoiceAction.storage);
  });

  test('tryParse returns null for unknown, empty or missing values', () {
    expect(InvoiceAction.tryParse('other'), isNull);
    expect(InvoiceAction.tryParse(''), isNull);
    expect(InvoiceAction.tryParse(null), isNull);
  });
}