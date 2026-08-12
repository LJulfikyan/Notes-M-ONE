import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/notes/data/notes_database.dart';
import 'features/notes/data/sqlite_notes_repository.dart';
import 'features/notes/presentation/pages/home_page.dart';
import 'features/notes/presentation/stores/notes_store.dart';

class NotesApp extends StatelessWidget {
  NotesApp({super.key, NotesStore? notesStore})
    : _notesStore =
          notesStore ?? NotesStore(SqliteNotesRepository(NotesDatabase()));

  final NotesStore _notesStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: AppTheme.dark,
      home: HomePage(store: _notesStore),
    );
  }
}
