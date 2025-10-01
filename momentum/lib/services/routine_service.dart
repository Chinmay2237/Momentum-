
import 'package:flutter/material.dart';
import 'package:momentum/models/routine.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RoutineService {
  static Database? _database;
  static const String _tableName = 'routines';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'routines.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, hour INTEGER, minute INTEGER, isCompleted INTEGER, completedAt TEXT)',
        );
      },
    );
  }

  Future<void> addRoutine(String title, TimeOfDay time) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'title': title,
        'hour': time.hour,
        'minute': time.minute,
        'isCompleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Routine.fromMap(maps[i]);
    });
  }

  Future<void> toggleCompleted(int id, bool isCompleted) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
