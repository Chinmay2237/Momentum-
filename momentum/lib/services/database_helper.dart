
import 'package:momentum/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'momentum.db');

    return await openDatabase(
      path,
      version: 3, // Incremented version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await _createNotesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createNotesTable(db);
    }
    if (oldVersion < 3) {
      // Add color column and drop sketch column
      await db.execute('ALTER TABLE notes ADD COLUMN color INTEGER NOT NULL DEFAULT 4294967295;'); // Default to white
      // A direct drop of the column is not supported in SQLite,
      // so we will create a new table and copy the data.
      await db.execute('''
        CREATE TABLE notes_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          color INTEGER NOT NULL DEFAULT 4294967295
        )
      ''');
      await db.execute('INSERT INTO notes_new(id, title, content, createdAt) SELECT id, title, content, createdAt FROM notes;');
      await db.execute('DROP TABLE notes;');
      await db.execute('ALTER TABLE notes_new RENAME TO notes;');
    }
  }

  Future<void> _createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        color INTEGER NOT NULL DEFAULT 4294967295
      )
    ''');
  }

  Future<int> createUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> createNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
