import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_colors.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_editor_page.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_reader_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('reader presents the complete saved title and body', (
    tester,
  ) async {
    final note = _note(
      title: 'Book Review: The Design of Everyday Things',
      body: 'First paragraph.\n\nSecond paragraph remains plain text.',
    );

    await _pumpReader(tester, NotesStore(SwipeTestRepository([note])), note);

    expect(find.text(note.title), findsOneWidget);
    expect(find.text(note.body), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('reader-title')))
          .style
          ?.fontSize,
      34,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('reader-body')))
          .style
          ?.fontSize,
      18,
    );
  });

  testWidgets('long reader content scrolls without overflow', (tester) async {
    final note = _note(
      title: 'A long multiline reader title that wraps naturally on screen',
      body: List.filled(
        18,
        'A complete plain-text paragraph remains readable and scrollable.',
      ).join('\n\n'),
    );

    await _pumpReader(tester, NotesStore(SwipeTestRepository([note])), note);
    await tester.drag(
      find.byKey(const ValueKey('reader-scroll-view')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reader Edit opens the editor for the correct note', (
    tester,
  ) async {
    final note = _note(title: 'Correct note', body: 'Correct body');

    await _pumpReader(tester, NotesStore(SwipeTestRepository([note])), note);
    await tester.tap(find.byTooltip('Edit note'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditorPage), findsOneWidget);
    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.first).controller?.text, note.title);
    expect(tester.widget<TextField>(fields.last).controller?.text, note.body);
  });

  testWidgets('reader Back returns to the previous screen', (tester) async {
    final note = _note();
    final store = NotesStore(SwipeTestRepository([note]));
    await _setSurface(tester);
    await tester.pumpWidget(_readerLauncher(store, note));
    await tester.tap(find.byKey(const ValueKey('open-reader')));
    await tester.pumpAndSettle();
    expect(find.byType(NoteReaderPage), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reader-origin')), findsOneWidget);
    expect(find.byType(NoteReaderPage), findsNothing);
  });

  testWidgets('Reader Edit Preview Edit Save refreshes the reader', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);
    final store = NotesStore(repository);
    await store.load();

    await _pumpReader(tester, store, note);
    await tester.tap(find.byTooltip('Edit note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Updated title');
    await tester.enterText(find.byType(TextField).last, 'Updated body');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Preview note'));
    await tester.pumpAndSettle();
    expect(find.text('Updated title'), findsOneWidget);
    expect(find.text('Updated body'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit note'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.tap(find.byTooltip('Save note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteReaderPage), findsOneWidget);
    expect(find.text('Updated title'), findsOneWidget);
    expect(find.text('Updated body'), findsOneWidget);
    expect((await repository.getNotes()).single.title, 'Updated title');
  });

  testWidgets('reader reference geometry keeps controls inside page insets', (
    tester,
  ) async {
    final note = _note();

    await _pumpReader(tester, NotesStore(SwipeTestRepository([note])), note);

    final backRect = tester.getRect(
      find.byKey(const ValueKey('reader-back-control')),
    );
    final editRect = tester.getRect(
      find.byKey(const ValueKey('reader-edit-control')),
    );
    expect(backRect.left, 23);
    expect(backRect.top, 24);
    expect(backRect.size, const Size.square(50));
    expect(editRect.right, 370);
    expect(editRect.size, const Size.square(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reader supports increased text scale without overflow', (
    tester,
  ) async {
    final note = _note(
      title: 'A long accessible reader title that wraps naturally',
      body: List.filled(
        8,
        'Accessible plain-text body paragraph.',
      ).join('\n\n'),
    );

    await _pumpReader(
      tester,
      NotesStore(SwipeTestRepository([note])),
      note,
      textScale: 1.5,
    );

    expect(find.byKey(const ValueKey('reader-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('reader-body')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dirty Save opens modal without persisting changes', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);
    final store = NotesStore(repository);

    await _openEditor(tester, store, note);
    await tester.enterText(find.byType(TextField).first, 'Pending title');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Save note'));
    await tester.pumpAndSettle();

    expect(find.text('Save changes?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('editor-confirmation-dialog')),
      findsOneWidget,
    );
    expect((await repository.getNotes()).single.title, 'Saved title');
    expect((await repository.getDraft('note-1'))?.title, 'Pending title');
  });

  testWidgets('Save commits the draft and clears it', (tester) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);
    final store = NotesStore(repository);
    await store.load();

    await _openEditor(tester, store, note);
    await tester.enterText(find.byType(TextField).first, 'Committed title');
    await tester.enterText(find.byType(TextField).last, 'Committed body');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Save note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = (await repository.getNotes()).single;
    expect(saved.title, 'Committed title');
    expect(saved.body, 'Committed body');
    expect(await repository.getDraft('note-1'), isNull);
    expect(find.byKey(const ValueKey('editor-origin')), findsOneWidget);
  });

  testWidgets('Save-dialog Discard preserves saved note and clears draft', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);

    await _openEditor(tester, NotesStore(repository), note);
    await tester.enterText(find.byType(TextField).first, 'Discard me');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Save note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect((await repository.getNotes()).single.title, 'Saved title');
    expect(await repository.getDraft('note-1'), isNull);
    expect(find.byKey(const ValueKey('editor-origin')), findsOneWidget);
  });

  testWidgets('dirty Back opens the discard dialog', (tester) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);

    await _openEditor(tester, NotesStore(repository), note);
    await tester.enterText(find.byType(TextField).last, 'Pending body');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(
      find.text('Are you sure you want to discard changes?'),
      findsOneWidget,
    );
    expect(find.text('Keep'), findsOneWidget);
  });

  testWidgets('Keep returns to editor with the complete draft intact', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);

    await _openEditor(tester, NotesStore(repository), note);
    await tester.enterText(find.byType(TextField).first, 'Kept title');
    await tester.enterText(find.byType(TextField).last, 'Kept body');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(
      tester.widget<TextField>(fields.first).controller?.text,
      'Kept title',
    );
    expect(tester.widget<TextField>(fields.last).controller?.text, 'Kept body');
    expect((await repository.getDraft('note-1'))?.body, 'Kept body');
    expect(find.byType(NoteEditorPage), findsOneWidget);
  });

  testWidgets('Back-dialog Discard leaves without modifying saved note', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);

    await _openEditor(tester, NotesStore(repository), note);
    await tester.enterText(find.byType(TextField).first, 'Discarded title');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect((await repository.getNotes()).single.title, 'Saved title');
    expect(await repository.getDraft('note-1'), isNull);
    expect(find.byKey(const ValueKey('editor-origin')), findsOneWidget);
  });

  testWidgets('clean Back leaves immediately without a dialog', (tester) async {
    final note = _note();

    await _openEditor(tester, NotesStore(SwipeTestRepository([note])), note);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('editor-origin')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('editor-confirmation-dialog')),
      findsNothing,
    );
  });

  testWidgets('modal matches reference geometry without overflow', (
    tester,
  ) async {
    final note = _note();

    await _openEditor(tester, NotesStore(SwipeTestRepository([note])), note);
    await tester.enterText(find.byType(TextField).first, 'Pending title');
    await tester.tap(find.byTooltip('Save note'));
    await tester.pumpAndSettle();

    final dialogRect = tester.getRect(
      find.byKey(const ValueKey('editor-confirmation-dialog')),
    );
    final discardRect = tester.getRect(
      find.byKey(const ValueKey('dialog-discard-action')),
    );
    final saveRect = tester.getRect(
      find.byKey(const ValueKey('dialog-save-action')),
    );
    final infoRect = tester.getRect(find.byIcon(Icons.info_rounded));
    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialogRect.width, closeTo(313, 1));
    expect(dialogRect.height, closeTo(225, 1));
    expect(dialog.backgroundColor, AppColors.background);
    expect(infoRect.center.dy - dialogRect.top, closeTo(57, 1));
    expect(discardRect.top - dialogRect.top, closeTo(152, 1));
    expect(discardRect.size, const Size(105, 37));
    expect(saveRect.size, const Size(105, 37));
    expect(saveRect.left - discardRect.right, 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scaled dialog keeps both actions visible without clipping', (
    tester,
  ) async {
    final note = _note();

    await _openEditor(
      tester,
      NotesStore(SwipeTestRepository([note])),
      note,
      size: const Size(320, 720),
      textScale: 1.5,
    );
    await tester.enterText(find.byType(TextField).last, 'Pending body');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dialog-discard-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('dialog-keep-action')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpReader(
  WidgetTester tester,
  NotesStore store,
  Note note, {
  double textScale = 1,
}) async {
  await _setSurface(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: NoteReaderPage(store: store, note: note),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openEditor(
  WidgetTester tester,
  NotesStore store,
  Note note, {
  Size size = const Size(393, 852),
  double textScale = 1,
}) async {
  await _setSurface(tester, size);
  await tester.pumpWidget(_editorLauncher(store, note, textScale));
  await tester.tap(find.byKey(const ValueKey('open-editor')));
  await tester.pumpAndSettle();
}

Future<void> _setSurface(
  WidgetTester tester, [
  Size size = const Size(393, 852),
]) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _readerLauncher(NotesStore store, Note note) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            key: const ValueKey('open-reader'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => NoteReaderPage(store: store, note: note),
              ),
            ),
            child: const Text('Reader origin', key: ValueKey('reader-origin')),
          ),
        ),
      ),
    ),
  );
}

Widget _editorLauncher(NotesStore store, Note note, double textScale) {
  return MaterialApp(
    theme: AppTheme.dark,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            key: const ValueKey('open-editor'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => NoteEditorPage(store: store, note: note),
              ),
            ),
            child: const Text('Editor origin', key: ValueKey('editor-origin')),
          ),
        ),
      ),
    ),
  );
}

Note _note({String title = 'Saved title', String body = 'Saved body'}) {
  return Note(
    id: 1,
    title: title,
    body: body,
    color: NoteColor.pink,
    isFavorite: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}
