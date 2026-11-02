import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_database_test_',
    );
    database = await AppDatabase.open(
      path: '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite',
    );
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('initializes SQLite with schema version 1', () async {
    expect(database.schemaVersion, 1);
    expect(await database.storedSchemaVersion, 1);
  });

  test('commits and rolls back Drift transactions', () async {
    await database.customStatement(
      'CREATE TABLE transaction_probe (value TEXT NOT NULL)',
    );

    await database.transaction(() async {
      await database.customStatement(
        'INSERT INTO transaction_probe (value) VALUES (?)',
        ['committed'],
      );
    });

    expect(
      await database
          .customSelect('SELECT value FROM transaction_probe')
          .map((row) => row.read<String>('value'))
          .get(),
      ['committed'],
    );

    await expectLater(
      database.transaction(() async {
        await database.customStatement(
          'INSERT INTO transaction_probe (value) VALUES (?)',
          ['rolled back'],
        );
        throw StateError('Force transaction rollback');
      }),
      throwsA(isA<StateError>()),
    );

    expect(
      await database
          .customSelect('SELECT value FROM transaction_probe')
          .map((row) => row.read<String>('value'))
          .get(),
      ['committed'],
    );
  });
}
