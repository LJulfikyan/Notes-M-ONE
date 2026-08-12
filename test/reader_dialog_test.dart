import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_editor_page.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_reader_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('save, discard, and keep dialogs preserve the chosen outcome', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);
    final store = NotesStore(repository);
    await tester.pumpWidget(_editor(store, note));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Changed');
    await tester.tap(find.byTooltip('Save note'));
    await tester.pumpAndSettle();
    expect(find.text('Save changes?'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await repository.getNotes()).single.title, 'Changed');

    await tester.pumpWidget(
      _editor(store, note, key: const ValueKey('discard')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Discarded');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'Discarded',
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect((await repository.getNotes()).single.title, 'Changed');
  });

  testWidgets('reader opens the editor for its note', (tester) async {
    final note = _note();
    final store = NotesStore(SwipeTestRepository([note]));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: NoteReaderPage(store: store, note: note),
      ),
    );
    await tester.tap(find.byTooltip('Edit note'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteEditorPage), findsOneWidget);
  });
}

Widget _editor(NotesStore store, Note note, {Key? key}) => MaterialApp(
  theme: AppTheme.dark,
  home: NoteEditorPage(key: key, store: store, note: note),
);

Note _note() => Note(
  id: 1,
  title: 'Saved',
  body: 'Body',
  color: NoteColor.pink,
  isFavorite: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
