import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/search_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('empty search query renders the frame-07 blank state', (
    tester,
  ) async {
    final store = await _store();

    await tester.pumpWidget(_search(store));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Recipe ideas'), findsNothing);
    expect(find.text('File not found. Try searching again.'), findsNothing);
  });

  testWidgets('search matches a note body case-insensitively', (tester) async {
    final store = await _store();

    await tester.pumpWidget(_search(store));
    await tester.enterText(find.byType(TextField), 'KOREAN');
    await tester.pump();

    expect(find.text('Recipe ideas'), findsOneWidget);
    expect(find.text('Project planning'), findsNothing);
  });

  testWidgets('search shows the exact no-results copy and illustration', (
    tester,
  ) async {
    final store = await _store();

    await tester.pumpWidget(_search(store));
    await tester.enterText(find.byType(TextField), 'unmatched query');
    await tester.pump();

    expect(find.text('File not found. Try searching again.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('clear search returns to the blank state', (tester) async {
    final store = await _store();

    await tester.pumpWidget(_search(store));
    await tester.enterText(find.byType(TextField), 'Recipe');
    await tester.pump();
    expect(find.text('Recipe ideas'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(store.searchQuery, isEmpty);
    expect(find.text('Recipe ideas'), findsNothing);
    expect(find.text('File not found. Try searching again.'), findsNothing);
  });
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

Widget _search(NotesStore store) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: SearchPage(store: store),
  );
}
