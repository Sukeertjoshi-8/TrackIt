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
      version: 5,
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
        requires_photo_proof INTEGER NOT NULL DEFAULT 0,
        photoProofPath TEXT,
        tag TEXT NOT NULL DEFAULT 'Uncategorized',
        is_parent INTEGER NOT NULL DEFAULT 0,
        parent_id TEXT,
        frequency_days TEXT,
        skipped_sessions INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN tag TEXT NOT NULL DEFAULT "Uncategorized"');
    }
    if (oldVersion < 3) {
      // Rename requiresProof to requires_photo_proof
      await db.execute('ALTER TABLE tasks RENAME COLUMN requiresProof TO requires_photo_proof');
      
      // Add new Parent/Child tracking columns
      await db.execute('ALTER TABLE tasks ADD COLUMN is_parent INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE tasks ADD COLUMN parent_id TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN frequency_days TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN skipped_sessions INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE tasks RENAME COLUMN proofImagePath TO photoProofPath');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE tasks ADD COLUMN completed_at TEXT');
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
