import 'package:notes_m_one/features/notes/data/notes_repository.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/domain/note_draft.dart';

class SwipeTestRepository implements NotesRepository {
  SwipeTestRepository(List<Note> notes) : _notes = List.of(notes);

  final List<Note> _notes;
  final Map<String, NoteDraft> _drafts = {};

  @override
  Future<Note> createNote({
    required String title,
    required String body,
    NoteColor? color,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _notes.length + 1,
      title: title,
      body: body,
      color: color ?? NoteColor.magenta,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(note);
    return note;
  }

  @override
  Future<NoteColor> reserveNextColor() async => NoteColor.magenta;

  @override
  Future<void> deleteDraft(String id) async => _drafts.remove(id);

  @override
  Future<void> deleteNote(int id) async {
    _notes.removeWhere((note) => note.id == id);
  }

  @override
  Future<NoteDraft?> getDraft(String id) async => _drafts[id];

  @override
  Future<List<Note>> getNotes() async => List.of(_notes);

  @override
  Future<void> saveDraft(NoteDraft draft) async => _drafts[draft.id] = draft;

  @override
  Future<Note> toggleFavorite(Note note) async {
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    return updateNote(updated);
  }

  @override
  Future<Note> updateNote(Note note) async {
    final index = _notes.indexWhere(
      (existingNote) => existingNote.id == note.id,
    );
    _notes[index] = note;
    return note;
  }
}
