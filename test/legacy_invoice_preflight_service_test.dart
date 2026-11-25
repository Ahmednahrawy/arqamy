import 'dart:convert';
import 'dart:io';

import 'package:arqamy/core/services/legacy_invoice_preflight_service.dart';
import 'package:arqamy/core/services/legacy_invoice_snapshot_service.dart';
import 'package:arqamy/features/payment_ledger/data/legacy_invoice_audit.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _invoice({
  String id = 'invoice-1',
  double total = 50,
  double paid = 20,
  double rest = 30,
  String action = 'بيع',
}) =>
    {
      'id': id,
      'customerName': 'عميل',
      'products': [
        {
          'name': 'قمح',
          'weight': 10,
          'packageWeight': 0,
          'numberPackage': 0,
          'price': 5,
        },
      ],
      'totalCost': total,
      'paid': paid,
      'rest': rest,
      'formattedDate': 'Nov 25, 2026',
      'formattedTime': '10:30',
      'invoiceAction': action,
      'invoiceSerial': 'S-$id',
      'customerId': 'customer-1',
    };

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'arqamy_legacy_preflight_test_',
    );
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  Future<LegacyInvoiceSnapshot> snapshotFor(Object? value) {
    final raw = value is String ? value : jsonEncode(value);
    return LegacyInvoiceSnapshotService(
      readSource: () async => raw,
      directory: directory,
      clock: () => DateTime.utc(2026, 11, 25),
    ).capture();
  }

  const service = LegacyInvoicePreflightService();

  test('classifies a structurally and financially valid invoice as ready',
      () async {
    final record = jsonEncode(_invoice()).replaceFirst('"id":', '"id" : ');
    final snapshot = await snapshotFor('[  $record  ]');

    final report = await service.inspect(snapshot);

    expect(report.isComplete, isTrue);
    expect(report.totalOccurrences, 1);
    expect(report.count(LegacyInvoicePreflightClassification.ready), 1);
    expect(report.occurrences.single.sourceIndex, 0);
    expect(
      report.occurrences.single.sourceOccurrenceIdentity.snapshotSha256,
      snapshot.sha256,
    );
    expect(
      report.occurrences.single.sourceOccurrenceIdentity.recordSha256,
      isNotEmpty,
    );
    expect(report.occurrences.single.invoice?.id, 'invoice-1');
    expect(report.occurrences.single.rawJson, record);
    expect(report.occurrences.single.issues, isEmpty);
  });

  test('isolates malformed records and continues inspecting other records',
      () async {
    final snapshot = await snapshotFor([
      _invoice(),
      {'id': 'broken', 'products': 'not-a-list'},
      'not-an-invoice-object',
    ]);

    final report = await service.inspect(snapshot);

    expect(report.isComplete, isTrue);
    expect(report.totalOccurrences, 3);
    expect(report.count(LegacyInvoicePreflightClassification.ready), 1);
    expect(
      report.count(LegacyInvoicePreflightClassification.malformedRecord),
      2,
    );
    expect(report.occurrences[1].sourceIndex, 1);
    expect(report.occurrences[1].invoiceId, 'broken');
    expect(report.occurrences[1].malformedReasons, isNotEmpty);
    expect(report.occurrences[2].sourceIndex, 2);
  });

  test('holds every structurally valid occurrence with a duplicate invoice id',
      () async {
    final snapshot = await snapshotFor([
      _invoice(id: 'duplicate'),
      _invoice(id: 'duplicate'),
      _invoice(id: 'unique'),
    ]);

    final report = await service.inspect(snapshot);

    expect(
      report.count(LegacyInvoicePreflightClassification.duplicateIdentity),
      2,
    );
    expect(report.count(LegacyInvoicePreflightClassification.ready), 1);
    expect(
      report.occurrences.take(2).every(
            (item) => item.issues.contains(
              LegacyInvoiceIssue.duplicateInvoiceId,
            ),
          ),
      isTrue,
    );
  });

  test('classifies structurally valid records with audit findings for review',
      () async {
    final snapshot = await snapshotFor([
      _invoice(total: 50, paid: 60, rest: -10),
    ]);

    final report = await service.inspect(snapshot);

    expect(
      report.occurrences.single.classification,
      LegacyInvoicePreflightClassification.needsReview,
    );
    expect(
      report.occurrences.single.issues,
      contains(LegacyInvoiceIssue.overpaid),
    );
  });

  test('stops when the top-level JSON is invalid or not a list', () async {
    final invalidJson = await snapshotFor('[{"id":');
    final wrongShape = await snapshotFor({'invoice': _invoice()});

    final invalidReport = await service.inspect(invalidJson);
    final shapeReport = await service.inspect(wrongShape);

    expect(
      invalidReport.fatalIssue,
      LegacyInvoicePreflightFatalIssue.invalidJson,
    );
    expect(
      shapeReport.fatalIssue,
      LegacyInvoicePreflightFatalIssue.invalidTopLevelShape,
    );
    expect(invalidReport.occurrences, isEmpty);
    expect(shapeReport.occurrences, isEmpty);
  });

  test('stops if the snapshot bytes no longer match its recorded digest',
      () async {
    final snapshot = await snapshotFor([_invoice()]);
    await snapshot.rawFile.writeAsString('[]');

    final report = await service.inspect(snapshot);

    expect(
      report.fatalIssue,
      LegacyInvoicePreflightFatalIssue.snapshotIntegrityFailure,
    );
    expect(report.occurrences, isEmpty);
  });

  test('distinguishes an absent source preference from an empty JSON value',
      () async {
    final snapshot = await LegacyInvoiceSnapshotService(
      readSource: () async => null,
      directory: directory,
    ).capture();

    final report = await service.inspect(snapshot);

    expect(report.sourceExists, isFalse);
    expect(report.fatalIssue, LegacyInvoicePreflightFatalIssue.sourceMissing);
  });
  test('assigns stable but distinct identities to identical duplicate records',
      () async {
    final record = _invoice(id: 'duplicate');
    final snapshot = await snapshotFor([record, record]);

    final firstReport = await service.inspect(snapshot);
    final repeatedReport = await service.inspect(snapshot);

    final firstIdentity =
        firstReport.occurrences[0].sourceOccurrenceIdentity;
    final secondIdentity =
        firstReport.occurrences[1].sourceOccurrenceIdentity;

    expect(firstIdentity.key, isNot(secondIdentity.key));
    expect(firstIdentity.sourceIndex, 0);
    expect(secondIdentity.sourceIndex, 1);
    expect(firstIdentity.recordSha256, secondIdentity.recordSha256);
    expect(
      firstReport.occurrences.map((item) => item.sourceOccurrenceIdentity.key),
      repeatedReport.occurrences
          .map((item) => item.sourceOccurrenceIdentity.key),
    );
  });

  test('changes occurrence identity when the immutable snapshot changes',
      () async {
    final firstSnapshot = await snapshotFor([_invoice(id: 'same')]);
    final secondSnapshot = await snapshotFor([
      _invoice(id: 'same'),
      _invoice(id: 'additional'),
    ]);

    final first = (await service.inspect(firstSnapshot))
        .occurrences.single.sourceOccurrenceIdentity;
    final second = (await service.inspect(secondSnapshot))
        .occurrences.first.sourceOccurrenceIdentity;

    expect(first.sourceIndex, second.sourceIndex);
    expect(first.recordSha256, second.recordSha256);
    expect(first.snapshotSha256, isNot(second.snapshotSha256));
    expect(first.key, isNot(second.key));
  });

  test('assigns an occurrence identity to malformed records', () async {
    final snapshot = await snapshotFor([
      {'id': 'malformed'},
    ]);

    final report = await service.inspect(snapshot);
    final occurrence = report.occurrences.single;

    expect(
      occurrence.classification,
      LegacyInvoicePreflightClassification.malformedRecord,
    );
    expect(occurrence.sourceOccurrenceIdentity.sourceIndex, 0);
    expect(
      occurrence.sourceOccurrenceIdentity.snapshotSha256,
      snapshot.sha256,
    );
  });

}
