import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/features/notes/data/notes_repository.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/domain/note_draft.dart';
import 'package:notes_m_one/features/notes/domain/note_filter.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

void main() {
  group('NotesStore', () {
    test('derives default, favorite, recent, and search views', () async {
      final repository = MemoryNotesRepository(
        notes: [
          _note(
            id: 1,
            title: 'First',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 3),
          ),
          _note(
            id: 2,
            title: 'Favorite match',
            isFavorite: true,
            createdAt: DateTime(2026, 1, 3),
            updatedAt: DateTime(2026, 1, 2),
          ),
        ],
      );
      final store = NotesStore(repository);

      await store.load();
      expect(store.filteredNotes.map((note) => note.id), [2, 1]);

      store.setFilter(NoteFilter.favorites);
      expect(store.filteredNotes.map((note) => note.id), [2]);

      store.setFilter(NoteFilter.recent);
      expect(store.filteredNotes.map((note) => note.id), [1, 2]);

      store.setSearchQuery('match');
      expect(store.searchResults.map((note) => note.id), [2]);
      store.setSearchQuery('');
      expect(store.searchResults, isEmpty);
    });

    test(
      'creates a persisted color and keeps favorite changes after reload',
      () async {
        final repository = MemoryNotesRepository();
        final store = NotesStore(repository);

        final created = await store.create(title: 'A title', body: 'A body');
        expect(created.color, NoteColor.magenta);

        final favorite = await store.toggleFavorite(created);
        expect(favorite.isFavorite, isTrue);

        final reloadedStore = NotesStore(repository);
        await reloadedStore.load();
        expect(reloadedStore.notes.single.color, NoteColor.magenta);
        expect(reloadedStore.notes.single.isFavorite, isTrue);
      },
    );
  });

  group('MemoryNotesRepository', () {
    test('supports CRUD, draft persistence, and color cycling', () async {
      final repository = MemoryNotesRepository();
      final first = await repository.createNote(title: 'First', body: 'One');
      final second = await repository.createNote(title: 'Second', body: 'Two');

      expect(first.color, NoteColor.magenta);
      expect(second.color, NoteColor.pink);

      final updated = await repository.updateNote(
        first.copyWith(title: 'Edited'),
      );
      expect(updated.title, 'Edited');

      final draft = NoteDraft(
        id: 'note-1',
        noteId: 1,
        title: 'Draft title',
        body: 'Draft body',
        color: NoteColor.magenta,
        isFavorite: false,
        updatedAt: DateTime(2026),
      );
      await repository.saveDraft(draft);
      expect(await repository.getDraft('note-1'), same(draft));
      await repository.deleteDraft('note-1');
      expect(await repository.getDraft('note-1'), isNull);

      await repository.deleteNote(second.id);
      expect((await repository.getNotes()).map((note) => note.id), [first.id]);
    });
  });
}

class MemoryNotesRepository implements NotesRepository {
  MemoryNotesRepository({List<Note>? notes}) : _notes = List.of(notes ?? []);

  final List<Note> _notes;
  final Map<String, NoteDraft> _drafts = {};
  int _nextId = 1;
  int _nextColorIndex = 0;

  @override
  Future<Note> createNote({
    required String title,
    required String body,
    NoteColor? color,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _nextId++,
      title: title,
      body: body,
      color:
          color ??
          NoteColor.values[_nextColorIndex++ % NoteColor.values.length],
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(note);
    return note;
  }

  @override
  Future<NoteColor> reserveNextColor() async =>
      NoteColor.values[_nextColorIndex++ % NoteColor.values.length];

  @override
  Future<void> deleteDraft(String id) async => _drafts.remove(id);

  @override
  Future<void> deleteNote(int id) async =>
      _notes.removeWhere((note) => note.id == id);

  @override
  Future<NoteDraft?> getDraft(String id) async => _drafts[id];

  @override
  Future<List<Note>> getNotes() async => List.of(_notes);

  @override
  Future<void> saveDraft(NoteDraft draft) async => _drafts[draft.id] = draft;

  @override
  Future<Note> toggleFavorite(Note note) async {
    return updateNote(note.copyWith(isFavorite: !note.isFavorite));
  }

  @override
  Future<Note> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    final index = _notes.indexWhere(
      (existingNote) => existingNote.id == note.id,
    );
    _notes[index] = updated;
    return updated;
  }
}

Note _note({
  required int id,
  required String title,
  required DateTime createdAt,
  required DateTime updatedAt,
  bool isFavorite = false,
}) {
  return Note(
    id: id,
    title: title,
    body: '',
    color: NoteColor.magenta,
    isFavorite: isFavorite,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
