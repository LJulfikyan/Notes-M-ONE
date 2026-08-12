import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/home_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('home stays usable across widths, text scales, and list states', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final longTitle =
        'A deliberately long note title that must wrap naturally without '
        'overflowing a flexible card at any supported text scale';
    final longBody =
        'A deliberately long note body confirms that saved plain-text content '
        'does not affect the home list layout even when it is substantial.';
    final populatedNotes = [
      _note(id: 1, title: longTitle, body: longBody, color: NoteColor.pink),
      _note(
        id: 2,
        title: 'Favorite note',
        body: longBody,
        color: NoteColor.green,
        isFavorite: true,
      ),
    ];

    for (final width in [320.0, 390.0, 768.0]) {
      for (final textScale in [0.9, 1.0, 1.5]) {
        await tester.binding.setSurfaceSize(Size(width, 720));

        await tester.pumpWidget(_home([], textScale));
        await tester.pumpAndSettle();
        expect(find.text('Create your first note !'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(_home(populatedNotes, textScale));
        await tester.pumpAndSettle();
        expect(find.text(longTitle), findsOneWidget);
        expect(find.text('Favorite note'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('filter choices remain usable with long content', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 720));
    final notes = [
      _note(
        id: 1,
        title: 'A long non-favorite title that should wrap without overflowing',
        body: 'Body',
        color: NoteColor.pink,
      ),
      _note(
        id: 2,
        title: 'Favorite note',
        body: 'Body',
        color: NoteColor.green,
        isFavorite: true,
      ),
    ];

    await tester.pumpWidget(_home(notes, 1.5));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Show filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Favorite note'), findsOneWidget);
    expect(find.text(notes.first.title), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _home(List<Note> notes, double textScale) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: HomePage(
        key: ValueKey('${notes.length}-$textScale'),
        store: NotesStore(SwipeTestRepository(notes)),
      ),
    ),
  );
}

Note _note({
  required int id,
  required String title,
  required String body,
  required NoteColor color,
  bool isFavorite = false,
}) {
  final timestamp = DateTime(2026, 1, id);
  return Note(
    id: id,
    title: title,
    body: body,
    color: color,
    isFavorite: isFavorite,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
