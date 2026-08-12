import '../domain/note.dart';
import '../domain/note_draft.dart';

abstract interface class NotesRepository {
  Future<List<Note>> getNotes();

  Future<Note> createNote({required String title, required String body});

  Future<Note> updateNote(Note note);

  Future<void> deleteNote(int id);

  Future<Note> toggleFavorite(Note note);

  Future<void> saveDraft(NoteDraft draft);

  Future<NoteDraft?> getDraft(String id);

  Future<void> deleteDraft(String id);
}
