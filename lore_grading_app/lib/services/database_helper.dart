import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:lore_grading_app/models/task.dart';
import 'package:lore_grading_app/models/grade.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lore_grading.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Grades table
    await db.execute('''
      CREATE TABLE grades (
        id TEXT PRIMARY KEY,
        subject TEXT NOT NULL,
        assignmentName TEXT NOT NULL,
        score REAL NOT NULL,
        maxScore REAL NOT NULL,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        teacherComments TEXT,
        category TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // --- Task Methods ---

  Future<int> insertTask(Task task, {int isSynced = 0}) async {
    final db = await instance.database;
    final data = task.toJson();
    data['isCompleted'] = task.isCompleted ? 1 : 0;
    data['is_synced'] = isSynced;
    data['is_deleted'] = 0;

    return await db.insert(
      'tasks',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    // We only fetch active (not soft deleted) tasks
    final result = await db.query(
      'tasks',
      where: 'is_deleted = 0',
      orderBy: 'dueDate ASC',
    );

    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      map['isCompleted'] = map['isCompleted'] == 1;
      return Task.fromJson(map);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getRawTasks() async {
    final db = await instance.database;
    return await db.query('tasks', where: 'is_deleted = 0');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTasks() async {
    final db = await instance.database;
    return await db.query('tasks', where: 'is_synced = 0 AND is_deleted = 0');
  }

  Future<List<Map<String, dynamic>>> getDeletedTasks() async {
    final db = await instance.database;
    return await db.query('tasks', where: 'is_deleted = 1');
  }

  Future<int> updateTask(Task task, {int isSynced = 0}) async {
    final db = await instance.database;
    final data = task.toJson();
    data['isCompleted'] = task.isCompleted ? 1 : 0;
    data['is_synced'] = isSynced;

    return await db.update(
      'tasks',
      data,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Soft delete (mark is_deleted = 1 so sync coordinator can delete it from server later)
  Future<int> deleteTaskSoft(String id) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      {
        'is_deleted': 1,
        'is_synced': 0, // needs to sync this deletion to remote
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hard delete (remove completely from local SQLite database)
  Future<int> deleteTaskHard(String id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markTasksAsSynced(List<String> ids) async {
    final db = await instance.database;
    if (ids.isEmpty) return;
    
    await db.update(
      'tasks',
      {'is_synced': 1},
      where: 'id IN (${ids.map((_) => '?').join(', ')})',
      whereArgs: ids,
    );
  }

  // --- Grade Methods ---

  Future<int> insertGrade(Grade grade, {int isSynced = 0}) async {
    final db = await instance.database;
    final data = grade.toJson();
    data['is_synced'] = isSynced;

    return await db.insert(
      'grades',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Grade>> getGrades() async {
    final db = await instance.database;
    final result = await db.query('grades', orderBy: 'date DESC');

    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      return Grade.fromJson(map);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getUnsyncedGrades() async {
    final db = await instance.database;
    return await db.query('grades', where: 'is_synced = 0');
  }

  Future<void> markGradesAsSynced(List<String> ids) async {
    final db = await instance.database;
    if (ids.isEmpty) return;

    await db.update(
      'grades',
      {'is_synced': 1},
      where: 'id IN (${ids.map((_) => '?').join(', ')})',
      whereArgs: ids,
    );
  }

  // Check if a task is synced in local DB
  Future<bool> isTaskSynced(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      columns: ['is_synced'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return false;
    return result.first['is_synced'] == 1;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
