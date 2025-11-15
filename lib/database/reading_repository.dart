import 'package:diabetes_tracker/models/reading.dart';

import 'database_helper.dart';

class ReadingRepository {
  final DatabaseHelper dbHelper;

  ReadingRepository({String? databasePath})
    : dbHelper = DatabaseHelper(databasePath: databasePath);

  Future<int> addReading(Reading reading) async {
    final db = await dbHelper.database;
    return await db.insert('readings', reading.toMap());
  }

  Future<List<Reading>> getAllReadings() async {
    final db = await dbHelper.database;
    final maps = await db.query('readings', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return Reading.fromMap(maps[i]);
    });
  }

  Future<int> deleteReading(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllReadings() async {
    final db = await dbHelper.database;
    return await db.delete('readings');
  }

  Future<void> close() async {
    await dbHelper.close();
  }

  Future<List<Reading>> getReadingsInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'readings',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Reading.fromMap(maps[i]);
    });
  }
}
