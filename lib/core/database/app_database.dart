import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

class AppDatabase extends GeneratedDatabase {
  AppDatabase._(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  static Future<AppDatabase> open({required String path}) async {
    await File(path).parent.create(recursive: true);
    final database = AppDatabase._(NativeDatabase(File(path)));
    await database.storedSchemaVersion;
    return database;
  }

  Future<int> get storedSchemaVersion async {
    final row = await customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }
}
