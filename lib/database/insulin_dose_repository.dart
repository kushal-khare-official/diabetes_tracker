import 'package:diabetes_tracker/models/insulin_dose.dart';

import 'database_helper.dart';

class InsulinDoseRepository {
  final DatabaseHelper dbHelper;

  InsulinDoseRepository({String? databasePath})
    : dbHelper = DatabaseHelper(databasePath: databasePath);

  Future<int> addInsulinDose(InsulinDose insulinDose) async {
    final db = await dbHelper.database;
    return await db.insert('insulin_doses', insulinDose.toMap());
  }

  Future<List<InsulinDose>> getAllInsulinDoses() async {
    final db = await dbHelper.database;
    final maps = await db.query('insulin_doses', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return InsulinDose.fromMap(maps[i]);
    });
  }

  Future<int> deleteInsulinDose(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'insulin_doses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllInsulinDoses() async {
    final db = await dbHelper.database;
    return await db.delete('insulin_doses');
  }

  Future<void> close() async {
    await dbHelper.close();
  }

  Future<List<InsulinDose>> getInsulinDosesInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'insulin_doses',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return InsulinDose.fromMap(maps[i]);
    });
  }
}
