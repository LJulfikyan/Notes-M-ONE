import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_editor_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/editor_toolbar.dart';

import 'support/counting_navigator_observer.dart';
import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('new editor displays empty title and body state', (tester) async {
    final store = NotesStore(SwipeTestRepository([]));

    await _pumpEditor(tester, store, null);

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    expect(tester.widget<TextField>(fields.first).controller?.text, isEmpty);
    expect(tester.widget<TextField>(fields.last).controller?.text, isEmpty);
    expect(
      tester.widget<TextField>(fields.first).decoration?.hintText,
      'Title',
    );
    expect(
      tester.widget<TextField>(fields.last).decoration?.hintText,
      'Type something...',
    );
  });

  testWidgets('existing editor loads the complete saved title and body', (
    tester,
  ) async {
    final note = _note();

    await _pumpEditor(tester, NotesStore(SwipeTestRepository([note])), note);

    final fields = find.byType(TextField);
    expect(
      tester.widget<TextField>(fields.first).controller?.text,
      'Saved title',
    );
    expect(
      tester.widget<TextField>(fields.last).controller?.text,
      'Saved body',
    );
  });

  testWidgets('Eye switches the editor to an in-route preview', (tester) async {
    final note = _note();

    await _pumpEditor(tester, NotesStore(SwipeTestRepository([note])), note);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byTooltip('Preview note'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('editor-preview-title')), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-preview-body')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byType(NoteEditorPage), findsOneWidget);
  });

  testWidgets('preview displays unsaved editor draft changes', (tester) async {
    final note = _note();

    await _pumpEditor(tester, NotesStore(SwipeTestRepository([note])), note);
    await tester.enterText(
      find.byType(TextField).first,
      'Unsaved preview title',
    );
    await tester.enterText(find.byType(TextField).last, 'Unsaved preview body');
    await tester.tap(find.byTooltip('Preview note'));
    await tester.pumpAndSettle();

    expect(find.text('Unsaved preview title'), findsOneWidget);
    expect(find.text('Unsaved preview body'), findsOneWidget);
    expect(find.text('Saved title'), findsNothing);
    expect(find.text('Saved body'), findsNothing);
  });

  testWidgets('Preview Edit returns to the same editing session', (
    tester,
  ) async {
    final note = _note();

    await _pumpEditor(tester, NotesStore(SwipeTestRepository([note])), note);
    await tester.enterText(find.byType(TextField).first, 'Session title');
    await tester.enterText(find.byType(TextField).last, 'Session body');
    await tester.tap(find.byTooltip('Preview note'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit note'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    expect(
      tester.widget<TextField>(fields.first).controller?.text,
      'Session title',
    );
    expect(
      tester.widget<TextField>(fields.last).controller?.text,
      'Session body',
    );
  });

  testWidgets('repeated Edit and Preview switches keep header and route', (
    tester,
  ) async {
    final note = _note();
    final observer = CountingNavigatorObserver();

    await _pumpEditor(
      tester,
      NotesStore(SwipeTestRepository([note])),
      note,
      navigatorObservers: [observer],
    );
    expect(observer.pushCount, 1);
    final editBackRect = tester.getRect(
      find.byKey(const ValueKey('editor-back-control')),
    );
    final saveRect = tester.getRect(
      find.byKey(const ValueKey('editor-save-control')),
    );

    for (var index = 0; index < 4; index += 1) {
      await tester.tap(find.byTooltip('Preview note'));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byKey(const ValueKey('editor-back-control'))),
        editBackRect,
      );
      expect(
        tester.getRect(
          find.byKey(const ValueKey('editor-preview-edit-control')),
        ),
        saveRect,
      );
      expect(observer.pushCount, 1);

      await tester.tap(find.byTooltip('Edit note'));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byKey(const ValueKey('editor-back-control'))),
        editBackRect,
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('editor-save-control'))),
        saveRect,
      );
    }

    expect(observer.pushCount, 1);
    expect(find.byType(NoteEditorPage), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Back from Preview returns to Editor mode', (tester) async {
    final note = _note();

    await _pumpEditor(tester, NotesStore(SwipeTestRepository([note])), note);
    await tester.tap(find.byTooltip('Preview note'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('editor-preview-title')), findsNothing);
    expect(find.byType(NoteEditorPage), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('long title wraps naturally without overflow', (tester) async {
    final longTitle =
        'A deliberately long editor title that wraps across several lines';
    final note = _note(title: longTitle);

    await _pumpEditor(
      tester,
      NotesStore(SwipeTestRepository([note])),
      note,
      size: const Size(320, 720),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('editor-title-field'))).height,
      greaterThan(80),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing keeps the saved note unchanged before save', (
    tester,
  ) async {
    final note = _note();
    final repository = SwipeTestRepository([note]);
    final store = NotesStore(repository);

    await _pumpEditor(tester, store, note);
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

    await _pumpEditor(tester, NotesStore(repository), note);
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

    await _pumpEditor(tester, NotesStore(repository), null);
    await tester.enterText(find.byType(TextField).first, 'New draft');
    await tester.pump(const Duration(milliseconds: 400));
    expect((await repository.getDraft('new-note'))?.color, NoteColor.magenta);

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

  testWidgets('lifecycle interruption flushes a dirty draft immediately', (
    tester,
  ) async {
    final repository = SwipeTestRepository([]);
    await _pumpEditor(tester, NotesStore(repository), null);

    await tester.enterText(find.byType(TextField).first, 'Protected draft');
    await _sendLifecycleState(AppLifecycleState.paused);
    await tester.pump();

    expect((await repository.getDraft('new-note'))?.title, 'Protected draft');
    expect(tester.takeException(), isNull);
    await _sendLifecycleState(AppLifecycleState.resumed);
  });

  testWidgets('formatting controls leave the plain-text model unchanged', (
    tester,
  ) async {
    final repository = SwipeTestRepository([]);
    final store = NotesStore(repository);

    await _pumpEditor(tester, store, null, viewInsetsBottom: 300);
    await tester.enterText(find.byType(TextField).last, 'Plain text');
    await tester.tap(find.text('B'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      'Plain text',
    );
    expect((await repository.getDraft('new-note'))?.body, 'Plain text');
    expect(find.byIcon(Icons.functions_rounded), findsOneWidget);
  });

  testWidgets('toolbar follows keyboard visibility instead of staying pinned', (
    tester,
  ) async {
    final store = NotesStore(SwipeTestRepository([]));

    await _pumpEditor(tester, store, null);
    expect(find.byType(EditorToolbar), findsNothing);

    await _pumpEditor(tester, store, null, viewInsetsBottom: 300);
    expect(find.byType(EditorToolbar), findsOneWidget);
    expect(tester.getRect(find.byType(EditorToolbar)).bottom, closeTo(552, 1));

    await _pumpEditor(tester, store, null);
    expect(find.byType(EditorToolbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorite editor keeps complete content and uses outline star', (
    tester,
  ) async {
    const body =
        'First complete paragraph.\n\nSecond complete paragraph remains visible.';
    final note = _note(body: body, isFavorite: true);
    final repository = SwipeTestRepository([note]);

    await _pumpEditor(tester, NotesStore(repository), note);

    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      note.title,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      body,
    );
    expect((await repository.getNotes()).single.body, body);
  });

  testWidgets('reference editor geometry has separated inset controls', (
    tester,
  ) async {
    final note = _note();

    await _pumpEditor(tester, NotesStore(SwipeTestRepository([note])), note);

    final backRect = tester.getRect(
      find.byKey(const ValueKey('editor-back-control')),
    );
    final stateRect = tester.getRect(
      find.byKey(const ValueKey('editor-state-control')),
    );
    final saveRect = tester.getRect(
      find.byKey(const ValueKey('editor-save-control')),
    );
    expect(backRect.left, 23);
    expect(backRect.size, const Size.square(47));
    expect(stateRect.size, const Size.square(47));
    expect(saveRect.size, const Size.square(47));
    expect(saveRect.left - stateRect.right, 19);
    expect(saveRect.right, 370);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).style?.fontSize,
      48,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).style?.fontSize,
      23,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).style?.fontFamily,
      'Nunito',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).style?.fontFamily,
      'Nunito',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).style?.height,
      1,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).style?.height,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('increased text scale keeps controls and long content usable', (
    tester,
  ) async {
    final note = _note(
      title: 'A long multiline title that must remain completely editable',
      body: List.filled(
        8,
        'A longer body paragraph remains plain text and scrolls naturally.',
      ).join('\n\n'),
    );

    await _pumpEditor(
      tester,
      NotesStore(SwipeTestRepository([note])),
      note,
      size: const Size(320, 720),
      textScale: 1.5,
    );

    expect(find.byKey(const ValueKey('editor-title-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-body-field')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('editor-title-field'))).height,
      greaterThan(48 * 1.5),
    );
    final editorScrollable = find.descendant(
      of: find.byKey(const ValueKey('editor-scroll-view')),
      matching: find.byType(Scrollable),
    );
    final scrollState = tester.state<ScrollableState>(editorScrollable.first);
    expect(scrollState.position.maxScrollExtent, greaterThan(0));
    await tester.drag(
      find.byKey(const ValueKey('editor-scroll-view')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(scrollState.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpEditor(
  WidgetTester tester,
  NotesStore store,
  Note? note, {
  Size size = const Size(393, 852),
  double textScale = 1,
  double viewInsetsBottom = 0,
  List<NavigatorObserver> navigatorObservers = const [],
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _editor(
      store,
      note,
      textScale: textScale,
      viewInsetsBottom: viewInsetsBottom,
      navigatorObservers: navigatorObservers,
    ),
  );
  await tester.pumpAndSettle();
}

Widget _editor(
  NotesStore store,
  Note? note, {
  Key? key,
  double textScale = 1,
  double viewInsetsBottom = 0,
  List<NavigatorObserver> navigatorObservers = const [],
}) {
  return MaterialApp(
    theme: AppTheme.dark,
    navigatorObservers: navigatorObservers,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        viewInsets: EdgeInsets.only(bottom: viewInsetsBottom),
      ),
      child: child!,
    ),
    home: NoteEditorPage(key: key, store: store, note: note),
  );
}

Note _note({
  String title = 'Saved title',
  String body = 'Saved body',
  bool isFavorite = false,
}) {
  final timestamp = DateTime(2026);
  return Note(
    id: 1,
    title: title,
    body: body,
    color: NoteColor.pink,
    isFavorite: isFavorite,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

Future<void> _sendLifecycleState(AppLifecycleState state) {
  return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        SystemChannels.lifecycle.name,
        const StringCodec().encodeMessage('AppLifecycleState.${state.name}'),
        null,
      );
}
