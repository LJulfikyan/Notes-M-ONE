import 'package:sqflite/sqflite.dart';

import '../domain/note.dart';
import '../domain/note_color.dart';
import '../domain/note_draft.dart';
import 'notes_database.dart';
import 'notes_repository.dart';

class SqliteNotesRepository implements NotesRepository {
  SqliteNotesRepository(this._notesDatabase, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final NotesDatabase _notesDatabase;
  final DateTime Function() _clock;

  @override
  Future<List<Note>> getNotes() async {
    final database = await _notesDatabase.database;
    final rows = await database.query(
      'notes',
      orderBy: 'created_at DESC, id DESC',
    );
    return rows.map(_noteFromMap).toList(growable: false);
  }

  @override
  Future<Note> createNote({required String title, required String body}) async {
    final database = await _notesDatabase.database;
    final now = _clock();
    return database.transaction((transaction) async {
      final color = await _takeNextColor(transaction);
      final id = await transaction.insert('notes', {
        'title': title,
        'body': body,
        'color': color.storageValue,
        'is_favorite': 0,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });
      return Note(
        id: id,
        title: title,
        body: body,
        color: color,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<Note> updateNote(Note note) async {
    final database = await _notesDatabase.database;
    final updated = note.copyWith(updatedAt: _clock());
    await database.update(
      'notes',
      _noteToMap(updated),
      where: 'id = ?',
      whereArgs: [updated.id],
    );
    return updated;
  }

  @override
  Future<void> deleteNote(int id) async {
    final database = await _notesDatabase.database;
    await database.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Note> toggleFavorite(Note note) {
    return updateNote(note.copyWith(isFavorite: !note.isFavorite));
  }

  @override
  Future<void> saveDraft(NoteDraft draft) async {
    final database = await _notesDatabase.database;
    await database.insert(
      'note_drafts',
      _draftToMap(draft),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<NoteDraft?> getDraft(String id) async {
    final database = await _notesDatabase.database;
    final rows = await database.query(
      'note_drafts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _draftFromMap(rows.single);
  }

  @override
  Future<void> deleteDraft(String id) async {
    final database = await _notesDatabase.database;
    await database.delete('note_drafts', where: 'id = ?', whereArgs: [id]);
  }

  Future<NoteColor> _takeNextColor(Transaction transaction) async {
    final rows = await transaction.query(
      'app_state',
      where: 'key = ?',
      whereArgs: ['next_note_color_index'],
      limit: 1,
    );
    final index = rows.isEmpty ? 0 : int.parse(rows.single['value']! as String);
    final color = NoteColor.values[index % NoteColor.values.length];
    await transaction.insert('app_state', {
      'key': 'next_note_color_index',
      'value': ((index + 1) % NoteColor.values.length).toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return color;
  }

  Map<String, Object?> _noteToMap(Note note) => {
    'title': note.title,
    'body': note.body,
    'color': note.color.storageValue,
    'is_favorite': note.isFavorite ? 1 : 0,
    'created_at': note.createdAt.millisecondsSinceEpoch,
    'updated_at': note.updatedAt.millisecondsSinceEpoch,
  };

  Note _noteFromMap(Map<String, Object?> map) => Note(
    id: map['id']! as int,
    title: map['title']! as String,
    body: map['body']! as String,
    color: NoteColor.fromStorage(map['color']! as String),
    isFavorite: (map['is_favorite']! as int) == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']! as int),
  );

  Map<String, Object?> _draftToMap(NoteDraft draft) => {
    'id': draft.id,
    'note_id': draft.noteId,
    'title': draft.title,
    'body': draft.body,
    'color': draft.color.storageValue,
    'is_favorite': draft.isFavorite ? 1 : 0,
    'updated_at': draft.updatedAt.millisecondsSinceEpoch,
  };

  NoteDraft _draftFromMap(Map<String, Object?> map) => NoteDraft(
    id: map['id']! as String,
    noteId: map['note_id'] as int?,
    title: map['title']! as String,
    body: map['body']! as String,
    color: NoteColor.fromStorage(map['color']! as String),
    isFavorite: (map['is_favorite']! as int) == 1,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']! as int),
  );
}
