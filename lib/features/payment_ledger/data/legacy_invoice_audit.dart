import 'package:arqamy/core/helpers/invoice_action.dart';
import 'package:arqamy/core/helpers/money.dart';
import 'package:arqamy/features/orderscreen/data/models/invoice.dart';

/// Things worth a human look before a legacy invoice is imported into the
/// ledger (Decisions 29 and 40). Nothing here is fixed automatically.
enum LegacyInvoiceIssue {
  duplicateInvoiceId,
  unknownAction,
  noCustomerId,
  noProducts,
  amountOutOfRange,
  moreThanTwoDecimals,
  negativePaid,
  negativeTotal,
  zeroTotal,
  overpaid,
  restDiffersFromTotalMinusPaid,
  totalDiffersFromLines,
}

class LegacyInvoiceFinding {
  const LegacyInvoiceFinding({
    required this.invoiceId,
    required this.serial,
    required this.issues,
  });

  final String invoiceId;
  final String serial;
  final List<LegacyInvoiceIssue> issues;
}

class LegacyInvoiceAuditReport {
  const LegacyInvoiceAuditReport({
    required this.invoiceCount,
    required this.findings,
  });

  final int invoiceCount;

  /// Only invoices with at least one issue.
  final List<LegacyInvoiceFinding> findings;

  int get cleanCount => invoiceCount - findings.length;

  Map<LegacyInvoiceIssue, int> get countsByIssue {
    final counts = <LegacyInvoiceIssue, int>{};
    for (final finding in findings) {
      for (final issue in finding.issues) {
        counts[issue] = (counts[issue] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<LegacyInvoiceFinding> findingsFor(LegacyInvoiceIssue issue) => [
    for (final finding in findings)
      if (finding.issues.contains(issue)) finding,
  ];
}

/// Read-only readiness check of saved invoices before a ledger import.
class LegacyInvoiceAudit {
  const LegacyInvoiceAudit._();

  static LegacyInvoiceAuditReport run(Iterable<Invoice> invoices) {
    final list = invoices.toList();
    final idCounts = <String, int>{};
    for (final invoice in list) {
      idCounts[invoice.id] = (idCounts[invoice.id] ?? 0) + 1;
    }

    final findings = <LegacyInvoiceFinding>[];
    for (final invoice in list) {
      final issues = _issuesOf(invoice, duplicate: idCounts[invoice.id]! > 1);
      if (issues.isEmpty) continue;
      findings.add(
        LegacyInvoiceFinding(
          invoiceId: invoice.id,
          serial: invoice.invoiceSerial,
          issues: List.unmodifiable(issues),
        ),
      );
    }
    return LegacyInvoiceAuditReport(
      invoiceCount: list.length,
      findings: List.unmodifiable(findings),
    );
  }

  static List<LegacyInvoiceIssue> _issuesOf(
    Invoice invoice, {
    required bool duplicate,
  }) {
    final issues = <LegacyInvoiceIssue>[];
    if (duplicate) issues.add(LegacyInvoiceIssue.duplicateInvoiceId);
    if (InvoiceAction.tryParse(invoice.invoiceAction) == null) {
      issues.add(LegacyInvoiceIssue.unknownAction);
    }
    if (invoice.customerId == null) issues.add(LegacyInvoiceIssue.noCustomerId);
    if (invoice.products.isEmpty) issues.add(LegacyInvoiceIssue.noProducts);

    final total = Money.tryFromDouble(invoice.totalCost);
    final paid = Money.tryFromDouble(invoice.paid);
    final rest = Money.tryFromDouble(invoice.rest);
    final lineTotals = [
      for (final product in invoice.products)
        Money.tryFromDouble(product.netWeight * product.price),
    ];
    if (total == null ||
        paid == null ||
        rest == null ||
        lineTotals.contains(null)) {
      issues.add(LegacyInvoiceIssue.amountOutOfRange);
      return issues;
    }

    if (_hasExtraDecimals(invoice.totalCost) ||
        _hasExtraDecimals(invoice.paid) ||
        _hasExtraDecimals(invoice.rest)) {
      issues.add(LegacyInvoiceIssue.moreThanTwoDecimals);
    }
    if (paid.isNegative) issues.add(LegacyInvoiceIssue.negativePaid);
    if (total.isNegative) issues.add(LegacyInvoiceIssue.negativeTotal);
    if (total.isZero) issues.add(LegacyInvoiceIssue.zeroTotal);
    if (paid.compareTo(total.abs()) > 0) {
      issues.add(LegacyInvoiceIssue.overpaid);
    }
    if (rest != total.abs() - paid) {
      issues.add(LegacyInvoiceIssue.restDiffersFromTotalMinusPaid);
    }
    if (Money.sum(lineTotals.whereType<Money>()) != total) {
      issues.add(LegacyInvoiceIssue.totalDiffersFromLines);
    }
    return issues;
  }

  /// True when the stored number has more precision than 0.01 beyond
  /// floating-point noise.
  static bool _hasExtraDecimals(double value) =>
      (Money.fromDouble(value).toDouble() - value).abs() > 1e-9;
}