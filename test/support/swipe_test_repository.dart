import 'package:notes_m_one/features/notes/data/notes_repository.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_draft.dart';

class SwipeTestRepository implements NotesRepository {
  SwipeTestRepository(List<Note> notes) : _notes = List.of(notes);

  final List<Note> _notes;

  @override
  Future<Note> createNote({required String title, required String body}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDraft(String id) async => throw UnimplementedError();

  @override
  Future<void> deleteNote(int id) async {
    _notes.removeWhere((note) => note.id == id);
  }

  @override
  Future<NoteDraft?> getDraft(String id) async => throw UnimplementedError();

  @override
  Future<List<Note>> getNotes() async => List.of(_notes);

  @override
  Future<void> saveDraft(NoteDraft draft) async => throw UnimplementedError();

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
