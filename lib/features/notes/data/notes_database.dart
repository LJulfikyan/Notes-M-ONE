import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class NotesDatabase {
  NotesDatabase({String? databasePath}) : _databasePath = databasePath;

  final String? _databasePath;
  Database? _database;

  Future<Database> get database async {
    final existingDatabase = _database;
    if (existingDatabase != null) {
      return existingDatabase;
    }

    final basePath = _databasePath ?? await getDatabasesPath();
    final database = await openDatabase(
      path.join(basePath, 'notes_m_one.db'),
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            color TEXT NOT NULL,
            is_favorite INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE note_drafts(
            id TEXT PRIMARY KEY,
            note_id INTEGER,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            color TEXT NOT NULL,
            is_favorite INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE app_state(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
