import 'dart:convert';

import 'package:arqamy/features/orderscreen/data/models/invoice.dart' as legacy;
import 'package:uuid/uuid.dart';

enum LedgerPartyRole { customer, supplier }

enum LedgerInvoiceAction { sale, purchase, storage, unknown }

class LedgerCurrency {
  const LedgerCurrency({
    required this.code,
    required this.minorUnitScale,
    required this.displayName,
  });

  final String code;
  final int minorUnitScale;
  final String displayName;
}

class LedgerParty {
  const LedgerParty({required this.id, required this.displayName});

  final String id;
  final String displayName;
}

class LedgerFinancialAccount {
  const LedgerFinancialAccount({
    required this.id,
    required this.partyId,
    required this.role,
    required this.currencyCode,
  });

  final String id;
  final String partyId;
  final LedgerPartyRole role;
  final String currencyCode;
}

class LedgerInvoiceLineDraft {
  const LedgerInvoiceLineDraft({
    required this.id,
    required this.lineIndex,
    required this.productName,
    this.quantityDecimal,
    this.packageWeightDecimal,
    this.packageCount,
    this.unitPriceDecimal,
    this.lineTotalMinor,
    this.currencyCode,
    this.sourceJson,
  });

  final String id;
  final int lineIndex;
  final String productName;
  final String? quantityDecimal;
  final String? packageWeightDecimal;
  final int? packageCount;
  final String? unitPriceDecimal;
  final int? lineTotalMinor;
  final String? currencyCode;
  final String? sourceJson;
}

class LedgerInvoiceDraft {
  const LedgerInvoiceDraft({
    required this.id,
    required this.serial,
    required this.action,
    required this.lines,
    this.legacyRecordKey,
    this.legacyInvoiceId,
    this.sourceJson,
    this.partyId,
    this.partyRole,
    this.financialAccountId,
    this.currencyCode,
    this.legacyAction,
    this.totalMinor,
    this.legacyTotalValue,
    this.legacyPaidValue,
    this.legacyRemainingValue,
    this.issuedAt,
  });

  final String id;
  final String serial;
  final String? legacyRecordKey;
  final String? legacyInvoiceId;
  final String? sourceJson;
  final String? partyId;
  final LedgerPartyRole? partyRole;
  final String? financialAccountId;
  final String? currencyCode;
  final LedgerInvoiceAction action;
  final String? legacyAction;
  final int? totalMinor;
  final String? legacyTotalValue;
  final String? legacyPaidValue;
  final String? legacyRemainingValue;
  final DateTime? issuedAt;
  final List<LedgerInvoiceLineDraft> lines;
}

class LedgerInvoiceMapper {
  const LedgerInvoiceMapper({Uuid uuid = const Uuid()}) : _uuid = uuid;

  final Uuid _uuid;

  /// Creates an in-memory ledger draft; it does not persist or migrate data.
  ///
  /// The existing model has already decoded the stored JSON, so [sourceJson]
  /// is a snapshot from its serializer rather than the original JSON bytes.
  /// Legacy amounts stay in decimal text fields and are not converted to minor
  /// units without an explicitly resolved currency.
  LedgerInvoiceDraft fromExistingInvoice(legacy.Invoice invoice) {
    final legacyAction = invoice.invoiceAction;
    final action = switch (legacyAction) {
      'بيع' => LedgerInvoiceAction.sale,
      'شراء' => LedgerInvoiceAction.purchase,
      'تخزين' => LedgerInvoiceAction.storage,
      _ => LedgerInvoiceAction.unknown,
    };

    return LedgerInvoiceDraft(
      id: _uuid.v4(),
      serial: invoice.invoiceSerial,
      legacyInvoiceId: invoice.id,
      sourceJson: jsonEncode(invoice.toJson()),
      action: action,
      legacyAction: legacyAction,
      legacyTotalValue: invoice.totalCost.toString(),
      legacyPaidValue: invoice.paid.toString(),
      legacyRemainingValue: invoice.rest.toString(),
      lines: [
        for (var index = 0; index < invoice.products.length; index++)
          _mapLine(invoice, index),
      ],
    );
  }

  LedgerInvoiceLineDraft _mapLine(legacy.Invoice invoice, int index) {
    final product = invoice.products[index];
    return LedgerInvoiceLineDraft(
      id: _uuid.v4(),
      lineIndex: index,
      productName: product.name,
      quantityDecimal: product.weight.toString(),
      packageWeightDecimal: product.packageWeight.toString(),
      packageCount: product.numberPackage,
      unitPriceDecimal: product.price.toString(),
      sourceJson: jsonEncode({
        'name': product.name,
        'weight': product.weight,
        'packageWeight': product.packageWeight,
        'numberPackage': product.numberPackage,
        'price': product.price,
      }),
    );
  }
}
