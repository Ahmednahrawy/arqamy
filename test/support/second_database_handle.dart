import 'package:arqamy/core/database/app_database.dart';

/// Opens a second connection to the same database file for concurrency tests.
Future<AppDatabase> openSecondDatabaseHandle(String path) =>
    AppDatabase.open(path: path);
