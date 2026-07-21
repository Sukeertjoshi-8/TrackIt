import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'trackit_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        progress REAL NOT NULL,
        deadline TEXT NOT NULL,
        requiresProof INTEGER NOT NULL,
        proofImagePath TEXT,
        tag TEXT NOT NULL DEFAULT 'Uncategorized'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN tag TEXT NOT NULL DEFAULT "Uncategorized"');
    }
  }

  Future<void> insertTask(Map<String, dynamic> taskMap) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'tasks',
        taskMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<void> updateTask(Map<String, dynamic> taskMap) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'tasks',
        taskMap,
        where: 'id = ?',
        whereArgs: [taskMap['id']],
      );
    });
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
