import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_reader_page.dart';
import 'package:notes_m_one/features/notes/presentation/pages/search_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/embedded_raster_svg.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/no_search_results_view.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/note_card.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('empty search query renders the frame-07 blank state', (
    tester,
  ) async {
    final store = await _store();

    await _pumpSearch(tester, store);

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).autofocus, isTrue);
    expect(find.byIcon(Icons.search_rounded), findsNothing);
    expect(find.text('Recipe ideas'), findsNothing);
    expect(find.text('Project planning'), findsNothing);
    expect(find.byType(NoSearchResultsView), findsNothing);
    expect(find.byType(EmbeddedRasterSvg), findsNothing);
    expect(find.text('File not found. Try searching again.'), findsNothing);
  });

  testWidgets('search matches a note title', (tester) async {
    final store = await _store();

    await _pumpSearch(tester, store);
    await tester.enterText(find.byType(TextField), 'Project');
    await tester.pump();

    expect(find.text('Project planning'), findsOneWidget);
    expect(find.text('Recipe ideas'), findsNothing);
    expect(find.byType(NoteCard), findsOneWidget);
  });

  testWidgets('search matches a note body', (tester) async {
    final store = await _store();

    await _pumpSearch(tester, store);
    await tester.enterText(find.byType(TextField), 'milestone');
    await tester.pump();

    expect(find.text('Project planning'), findsOneWidget);
    expect(find.text('Recipe ideas'), findsNothing);
  });

  testWidgets('search matching is case-insensitive', (tester) async {
    final store = await _store();

    await _pumpSearch(tester, store);
    await tester.enterText(find.byType(TextField), 'kOrEaN');
    await tester.pump();

    expect(find.text('Recipe ideas'), findsOneWidget);
    expect(find.text('Project planning'), findsNothing);
  });

  testWidgets('search shows the exact no-results copy and illustration', (
    tester,
  ) async {
    final store = await _store();

    await _pumpSearch(tester, store);
    await tester.enterText(find.byType(TextField), 'unmatched query');
    await tester.pump();

    expect(find.byType(NoSearchResultsView), findsOneWidget);
    expect(find.text('File not found. Try searching again.'), findsOneWidget);
    final illustration = tester.widget<EmbeddedRasterSvg>(
      find.byType(EmbeddedRasterSvg),
    );
    expect(illustration.assetPath, 'assets/images/search_no_results.svg');
    expect(illustration.width, closeTo(320, 1));
    expect(illustration.height, closeTo(207.6, 1));
    final illustrationRect = tester.getRect(find.byType(EmbeddedRasterSvg));
    final messageRect = tester.getRect(
      find.text('File not found. Try searching again.'),
    );
    expect(illustrationRect.top, closeTo(77, 1));
    expect(messageRect.top - illustrationRect.bottom, closeTo(10, 1));
  });

  testWidgets('clear search returns to the blank state', (tester) async {
    final store = await _store();

    await _pumpSearch(tester, store);
    await tester.enterText(find.byType(TextField), 'Recipe');
    await tester.pump();
    expect(find.text('Recipe ideas'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(store.searchQuery, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    expect(find.text('Recipe ideas'), findsNothing);
    expect(find.byType(NoSearchResultsView), findsNothing);
    expect(find.byType(EmbeddedRasterSvg), findsNothing);
    expect(find.text('File not found. Try searching again.'), findsNothing);
  });

  testWidgets('tapping a result opens the existing reader', (tester) async {
    final store = await _store();

    await _pumpSearch(tester, store);
    await tester.enterText(find.byType(TextField), 'Project');
    await tester.pump();
    await tester.tap(find.text('Project planning'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteReaderPage), findsOneWidget);
    expect(find.text('Outline the next milestone.'), findsOneWidget);
  });

  testWidgets('reference viewport matches measured search-field geometry', (
    tester,
  ) async {
    final store = await _store();

    await _pumpSearch(tester, store);

    final fieldRect = tester.getRect(
      find.byKey(const ValueKey('search-field-surface')),
    );
    expect(fieldRect.left, closeTo(30, 0.5));
    expect(fieldRect.width, closeTo(341, 1));
    expect(fieldRect.height, 45);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search remains usable without overflow at a narrow width', (
    tester,
  ) async {
    final store = await _store();

    await _pumpSearch(tester, store, size: const Size(280, 640));
    await tester.enterText(find.byType(TextField), 'unmatched query');
    await tester.pump();

    final fieldRect = tester.getRect(
      find.byKey(const ValueKey('search-field-surface')),
    );
    expect(fieldRect.left, greaterThanOrEqualTo(20));
    expect(fieldRect.right, lessThanOrEqualTo(280));
    expect(find.byType(NoSearchResultsView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('increased text scale does not break the search layout', (
    tester,
  ) async {
    final store = await _store();

    await _pumpSearch(tester, store, textScale: 1.5);
    await tester.enterText(find.byType(TextField), 'unmatched query');
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const ValueKey('search-field-surface'))).height,
      45,
    );
    expect(find.text('File not found. Try searching again.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSearch(
  WidgetTester tester,
  NotesStore store, {
  Size size = const Size(393, 852),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_search(store, textScale));
  await tester.pump();
}

Future<NotesStore> _store() async {
  final timestamp = DateTime(2026);
  final store = NotesStore(
    SwipeTestRepository([
      Note(
        id: 1,
        title: 'Recipe ideas',
        body: 'Korean noodles for a quiet weekend.',
        color: NoteColor.pink,
        isFavorite: false,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      Note(
        id: 2,
        title: 'Project planning',
        body: 'Outline the next milestone.',
        color: NoteColor.green,
        isFavorite: false,
        createdAt: timestamp.add(const Duration(days: 1)),
        updatedAt: timestamp,
      ),
    ]),
  );
  await store.load();
  return store;
}

Widget _search(NotesStore store, double textScale) {
  return MaterialApp(
    theme: AppTheme.dark,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: SearchPage(store: store),
  );
}
