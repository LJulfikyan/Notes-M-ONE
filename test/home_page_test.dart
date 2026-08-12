import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/home_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/contained_icon_button.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/header_button.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/note_filter_chip.dart';

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

    for (final width in [320.0, 393.0, 768.0]) {
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

  testWidgets('reference viewport matches measured home geometry', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await tester.pumpWidget(_home([], 1));
    await tester.pumpAndSettle();

    final illustrationRect = tester.getRect(
      find.byKey(const ValueKey('empty-notes-illustration')),
    );
    expect(illustrationRect.width, closeTo(320, 1));
    expect(illustrationRect.height, closeTo(256, 1));
    expect(illustrationRect.left, closeTo(37, 1));
    expect(illustrationRect.top, closeTo(279, 1));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _home([
        _note(id: 1, title: 'Short', body: '', color: NoteColor.yellow),
      ], 1),
    );
    await tester.pumpAndSettle();

    final controls = find.descendant(
      of: find.byType(HeaderButton),
      matching: find.byType(ContainedIconButton),
    );
    expect(controls, findsNWidgets(2));
    final searchRect = tester.getRect(controls.at(0));
    final infoRect = tester.getRect(controls.at(1));
    expect(searchRect.size, const Size.square(47));
    expect(infoRect.size, const Size.square(47));
    expect(infoRect.left - searchRect.right, 12);

    final noteRect = tester.getRect(find.byType(NoteCard));
    expect(noteRect.left, 23);
    expect(noteRect.width, 348);
    expect(noteRect.height, closeTo(84, 1.5));
    expect(
      tester.getSize(find.byType(FloatingActionButton)),
      const Size.square(66),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reference filter controls stay left aligned', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      _home([_note(id: 1, title: 'Note', body: '', color: NoteColor.cyan)], 1),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Show filters'));
    await tester.pumpAndSettle();

    final filters = find.byType(NoteFilterChip);
    expect(filters, findsNWidgets(3));
    final allRect = tester.getRect(filters.at(0));
    final favoritesRect = tester.getRect(filters.at(1));
    final recentRect = tester.getRect(filters.at(2));
    expect(allRect.left, 23);
    expect(allRect.size, const Size(50, 35));
    expect(favoritesRect.left, 82);
    expect(favoritesRect.size, const Size(94, 35));
    expect(recentRect.left, 184);
    expect(recentRect.size, const Size(78, 35));
    expect(tester.takeException(), isNull);
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
