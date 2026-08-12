import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_editor_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('editing keeps the saved note unchanged before save', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);
    final store = NotesStore(repository);

    await tester.pumpWidget(_editor(store, note));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Changed title');
    await tester.pump(const Duration(milliseconds: 400));

    expect((await repository.getNotes()).single.title, 'Saved title');
    expect((await repository.getDraft('note-1'))?.title, 'Changed title');
  });

  testWidgets('existing-note draft survives editor and store recreation', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);

    await tester.pumpWidget(_editor(NotesStore(repository), note));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Recovered body');
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(
      _editor(NotesStore(repository), note, key: const ValueKey('restored')),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      'Recovered body',
    );
  });

  testWidgets('new-note draft recovers its text and assigned color', (
    tester,
  ) async {
    final repository = SwipeTestRepository([]);

    await tester.pumpWidget(_editor(NotesStore(repository), null));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'New draft');
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(
      _editor(
        NotesStore(repository),
        null,
        key: const ValueKey('new-restored'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'New draft',
    );
    expect((await repository.getDraft('new-note'))?.color, NoteColor.magenta);
  });

  testWidgets('formatting toolbar leaves plain text unchanged', (tester) async {
    final store = NotesStore(SwipeTestRepository([]));

    await tester.pumpWidget(_editor(store, null));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Plain text');
    await tester.tap(find.byIcon(Icons.format_bold));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      'Plain text',
    );
  });
}

Widget _editor(NotesStore store, Note? note, {Key? key}) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: NoteEditorPage(key: key, store: store, note: note),
  );
}

Note _note() {
  final timestamp = DateTime(2026);
  return Note(
    id: 1,
    title: 'Saved title',
    body: 'Saved body',
    color: NoteColor.pink,
    isFavorite: false,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
