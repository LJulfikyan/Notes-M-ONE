import 'package:mobx/mobx.dart';

import '../../data/notes_repository.dart';
import '../../domain/note.dart';
import '../../domain/note_filter.dart';

part 'notes_store.g.dart';

class NotesStore = NotesStoreBase with _$NotesStore;

abstract class NotesStoreBase with Store {
  NotesStoreBase(this._repository);

  final NotesRepository _repository;

  @observable
  ObservableList<Note> notes = ObservableList<Note>();

  @observable
  NoteFilter filter = NoteFilter.all;

  @observable
  String searchQuery = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  List<Note> get filteredNotes {
    final result = List<Note>.of(notes);
    switch (filter) {
      case NoteFilter.all:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case NoteFilter.favorites:
        result
          ..removeWhere((note) => !note.isFavorite)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case NoteFilter.recent:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return result;
  }

  @computed
  List<Note> get searchResults {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }
    final result = List<Note>.of(notes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result
        .where(
          (note) =>
              note.title.toLowerCase().contains(query) ||
              note.body.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    try {
      notes = ObservableList.of(await _repository.getNotes());
    } catch (error) {
      errorMessage = 'Unable to load notes.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<Note> create({required String title, required String body}) async {
    final note = await _repository.createNote(title: title, body: body);
    notes.add(note);
    return note;
  }

  @action
  Future<Note> update(Note note) async {
    final updatedNote = await _repository.updateNote(note);
    _replace(updatedNote);
    return updatedNote;
  }

  @action
  Future<void> delete(int id) async {
    await _repository.deleteNote(id);
    notes.removeWhere((note) => note.id == id);
  }

  @action
  Future<Note> toggleFavorite(Note note) async {
    final updatedNote = await _repository.toggleFavorite(note);
    _replace(updatedNote);
    return updatedNote;
  }

  @action
  void setFilter(NoteFilter value) => filter = value;

  @action
  void setSearchQuery(String value) => searchQuery = value;

  void _replace(Note note) {
    final index = notes.indexWhere(
      (existingNote) => existingNote.id == note.id,
    );
    if (index != -1) {
      notes[index] = note;
    }
  }
}
