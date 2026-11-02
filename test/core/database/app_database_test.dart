import 'dart:io';

import 'package:arqamy/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  late AppDatabase database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'arqamy_database_test_',
    );
    databasePath =
        '${temporaryDirectory.path}${Platform.pathSeparator}ledger.sqlite';
    database = await AppDatabase.open(path: databasePath);
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

  test('persists committed values after closing and reopening SQLite', () async {
    await database.customStatement(
      'CREATE TABLE transaction_probe (value TEXT NOT NULL)',
    );

    await database.transaction(() async {
      await database.customStatement(
        'INSERT INTO transaction_probe (value) VALUES (?)',
        ['persisted across reopen'],
      );
    });

    await database.close();
    database = await AppDatabase.open(path: databasePath);

    expect(
      await database
          .customSelect('SELECT value FROM transaction_probe')
          .map((row) => row.read<String>('value'))
          .get(),
      ['persisted across reopen'],
    );
  });
}
