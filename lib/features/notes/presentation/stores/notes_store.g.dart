// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NotesStore on NotesStoreBase, Store {
  Computed<List<Note>>? _$filteredNotesComputed;

  @override
  List<Note> get filteredNotes =>
      (_$filteredNotesComputed ??= Computed<List<Note>>(
        () => super.filteredNotes,
        name: 'NotesStoreBase.filteredNotes',
      )).value;
  Computed<List<Note>>? _$searchResultsComputed;

  @override
  List<Note> get searchResults =>
      (_$searchResultsComputed ??= Computed<List<Note>>(
        () => super.searchResults,
        name: 'NotesStoreBase.searchResults',
      )).value;

  late final _$notesAtom = Atom(name: 'NotesStoreBase.notes', context: context);

  @override
  ObservableList<Note> get notes {
    _$notesAtom.reportRead();
    return super.notes;
  }

  @override
  set notes(ObservableList<Note> value) {
    _$notesAtom.reportWrite(value, super.notes, () {
      super.notes = value;
    });
  }

  late final _$filterAtom = Atom(
    name: 'NotesStoreBase.filter',
    context: context,
  );

  @override
  NoteFilter get filter {
    _$filterAtom.reportRead();
    return super.filter;
  }

  @override
  set filter(NoteFilter value) {
    _$filterAtom.reportWrite(value, super.filter, () {
      super.filter = value;
    });
  }

  late final _$searchQueryAtom = Atom(
    name: 'NotesStoreBase.searchQuery',
    context: context,
  );

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'NotesStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'NotesStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    'NotesStoreBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$createAsyncAction = AsyncAction(
    'NotesStoreBase.create',
    context: context,
  );

  @override
  Future<Note> create({
    required String title,
    required String body,
    NoteColor? color,
  }) {
    return _$createAsyncAction.run(
      () => super.create(title: title, body: body, color: color),
    );
  }

  late final _$updateAsyncAction = AsyncAction(
    'NotesStoreBase.update',
    context: context,
  );

  @override
  Future<Note> update(Note note) {
    return _$updateAsyncAction.run(() => super.update(note));
  }

  late final _$deleteAsyncAction = AsyncAction(
    'NotesStoreBase.delete',
    context: context,
  );

  @override
  Future<void> delete(int id) {
    return _$deleteAsyncAction.run(() => super.delete(id));
  }

  late final _$toggleFavoriteAsyncAction = AsyncAction(
    'NotesStoreBase.toggleFavorite',
    context: context,
  );

  @override
  Future<Note> toggleFavorite(Note note) {
    return _$toggleFavoriteAsyncAction.run(() => super.toggleFavorite(note));
  }

  late final _$NotesStoreBaseActionController = ActionController(
    name: 'NotesStoreBase',
    context: context,
  );

  @override
  void setFilter(NoteFilter value) {
    final _$actionInfo = _$NotesStoreBaseActionController.startAction(
      name: 'NotesStoreBase.setFilter',
    );
    try {
      return super.setFilter(value);
    } finally {
      _$NotesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchQuery(String value) {
    final _$actionInfo = _$NotesStoreBaseActionController.startAction(
      name: 'NotesStoreBase.setSearchQuery',
    );
    try {
      return super.setSearchQuery(value);
    } finally {
      _$NotesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
notes: ${notes},
filter: ${filter},
searchQuery: ${searchQuery},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
filteredNotes: ${filteredNotes},
searchResults: ${searchResults}
    ''';
  }
}
