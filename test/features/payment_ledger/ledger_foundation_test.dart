import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart' as legacy;
import 'package:arqamy/features/orderscreen/data/models/product_model.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation.dart';
import 'package:arqamy/features/payment_ledger/data/ledger_foundation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

legacy.Invoice _legacyInvoice({
  String id = 'legacy-invoice-id',
  String serial = 'serial-1',
  String action = 'تخزين',
}) {
  return legacy.Invoice(
    id: id,
    customerName: 'Unresolved customer',
    products: [
      Product(
        name: 'Rice',
        weight: 0.30000000000000004,
        packageWeight: 0.1,
        numberPackage: 2,
        price: 12.345,
      ),
    ],
    totalCost: 0.30000000000000004,
    paid: 0.1,
    rest: 0.20000000000000004,
    formattedDate: 'Not parsed',
    formattedTime: 'Not parsed',
    invoiceAction: action,
    invoiceSerial: serial,
  );
}

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;
  late LedgerFoundationRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'saved_invoices': '[{"id":"still-authoritative"}]',
    });
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_ledger_foundation_test_',
    );
    final path =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: path);
    repository = LedgerFoundationRepository(database);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'creates stable party roles and separate currency-specific accounts',
    () async {
      await repository.addCurrency(
        const LedgerCurrency(
          code: 'EGP',
          minorUnitScale: 2,
          displayName: 'Egyptian pound',
        ),
      );
      await repository.addCurrency(
        const LedgerCurrency(
          code: 'USD',
          minorUnitScale: 2,
          displayName: 'US dollar',
        ),
      );
      final party = await repository.createParty(displayName: 'Same party');
      await repository.addPartyRole(
        partyId: party.id,
        role: LedgerPartyRole.customer,
      );
      await repository.addPartyRole(
        partyId: party.id,
        role: LedgerPartyRole.supplier,
      );

      final customerEgp = await repository.createFinancialAccount(
        partyId: party.id,
        role: LedgerPartyRole.customer,
        currencyCode: 'EGP',
      );
      final customerUsd = await repository.createFinancialAccount(
        partyId: party.id,
        role: LedgerPartyRole.customer,
        currencyCode: 'USD',
      );
      final supplierEgp = await repository.createFinancialAccount(
        partyId: party.id,
        role: LedgerPartyRole.supplier,
        currencyCode: 'EGP',
      );

      expect(party.id, isNotEmpty);
      expect(customerEgp.id, isNot(customerUsd.id));
      expect(customerEgp.role, LedgerPartyRole.customer);
      expect(customerEgp.currencyCode, 'EGP');
      expect(customerUsd.currencyCode, 'USD');
      expect(supplierEgp.role, LedgerPartyRole.supplier);
      expect(supplierEgp.id, isNot(customerEgp.id));
    },
  );

  test(
    'maps legacy values without assuming identity, date, or currency',
    () async {
      final oldInvoice = _legacyInvoice();
      final draft = const LedgerInvoiceMapper().fromExistingInvoice(oldInvoice);

      expect(draft.id, isNot(oldInvoice.id));
      expect(draft.legacyInvoiceId, oldInvoice.id);
      expect(draft.serial, oldInvoice.invoiceSerial);
      expect(draft.action, LedgerInvoiceAction.storage);
      expect(draft.legacyAction, 'تخزين');
      expect(draft.partyId, isNull);
      expect(draft.partyRole, isNull);
      expect(draft.financialAccountId, isNull);
      expect(draft.currencyCode, isNull);
      expect(draft.totalMinor, isNull);
      expect(draft.issuedAt, isNull);
      expect(draft.legacyTotalValue, oldInvoice.totalCost.toString());
      expect(draft.legacyPaidValue, oldInvoice.paid.toString());
      expect(draft.legacyRemainingValue, oldInvoice.rest.toString());
      expect(
        draft.lines.single.quantityDecimal,
        oldInvoice.products.single.weight.toString(),
      );
      expect(
        draft.lines.single.unitPriceDecimal,
        oldInvoice.products.single.price.toString(),
      );
      expect(draft.lines.single.lineTotalMinor, isNull);
      expect(draft.lines.single.currencyCode, isNull);
      expect(
        (jsonDecode(draft.sourceJson!) as Map<String, dynamic>)['customerName'],
        oldInvoice.customerName,
      );

      await repository.saveInvoiceDraft(draft);
      final saved = await repository.getInvoice(draft.id);
      final savedLines = await repository.getInvoiceLines(draft.id);
      expect(saved, isNotNull);
      expect(saved!.legacyInvoiceId, oldInvoice.id);
      expect(saved.totalMinor, isNull);
      expect(saved.currencyCode, isNull);
      expect(savedLines, hasLength(1));
      expect(
        savedLines.single.quantityDecimal,
        oldInvoice.products.single.weight.toString(),
      );

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('saved_invoices'),
        '[{"id":"still-authoritative"}]',
      );
    },
  );

  test(
    'duplicate legacy IDs and serials remain evidence, not primary keys',
    () async {
      final oldInvoice = _legacyInvoice();
      final first = const LedgerInvoiceMapper().fromExistingInvoice(oldInvoice);
      final second = const LedgerInvoiceMapper().fromExistingInvoice(
        oldInvoice,
      );

      expect(first.id, isNot(second.id));
      await repository.saveInvoiceDraft(first);
      await repository.saveInvoiceDraft(second);

      final invoices = await database.select(database.invoices).get();
      expect(invoices, hasLength(2));
      expect(invoices.map((invoice) => invoice.legacyInvoiceId), {
        oldInvoice.id,
      });
      expect(invoices.map((invoice) => invoice.serial), {
        oldInvoice.invoiceSerial,
      });
    },
  );

  test('rejects mismatched party-role-account links atomically', () async {
    await repository.addCurrency(
      const LedgerCurrency(
        code: 'EGP',
        minorUnitScale: 2,
        displayName: 'Egyptian pound',
      ),
    );
    final party = await repository.createParty(displayName: 'Party');
    await repository.addPartyRole(
      partyId: party.id,
      role: LedgerPartyRole.customer,
    );
    await repository.addPartyRole(
      partyId: party.id,
      role: LedgerPartyRole.supplier,
    );
    final supplierAccount = await repository.createFinancialAccount(
      partyId: party.id,
      role: LedgerPartyRole.supplier,
      currencyCode: 'EGP',
    );

    final mapped = const LedgerInvoiceMapper().fromExistingInvoice(
      _legacyInvoice(action: 'بيع'),
    );
    final mismatchedDraft = LedgerInvoiceDraft(
      id: mapped.id,
      serial: mapped.serial,
      action: mapped.action,
      legacyInvoiceId: mapped.legacyInvoiceId,
      sourceJson: mapped.sourceJson,
      partyId: party.id,
      partyRole: LedgerPartyRole.customer,
      financialAccountId: supplierAccount.id,
      currencyCode: 'EGP',
      lines: mapped.lines,
    );

    await expectLater(
      repository.saveInvoiceDraft(mismatchedDraft),
      throwsA(anything),
    );
    expect(await repository.getInvoice(mapped.id), isNull);
    expect(await repository.getInvoiceLines(mapped.id), isEmpty);
  });
}
