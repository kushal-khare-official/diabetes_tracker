import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final String? _databasePath;

  factory DatabaseHelper({String? databasePath}) {
    if (databasePath != null) {
      return DatabaseHelper._internal(databasePath: databasePath);
    }
    return _instance;
  }

  DatabaseHelper._internal({String? databasePath})
    : _databasePath = databasePath;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path =
        _databasePath ?? join(await getDatabasesPath(), 'diabetes_tracker.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE readings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sugar_level INTEGER NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE insulin_doses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        units INTEGER NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
