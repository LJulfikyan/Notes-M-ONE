import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/home_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('a short note is closed and its foreground fills the row', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final store = NotesStore(SwipeTestRepository([_note(1, title: 'Short')]));
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    final foreground = find.byKey(const ValueKey('swipe-translation-1'));
    expect(tester.getSize(foreground).width, 348);
    expect(tester.getSize(foreground).height, closeTo(106, 1.5));
    expect(_translation(tester, 1), 0);
    expect(find.byKey(const ValueKey('swipe-delete-background')), findsNothing);
    expect(
      find.byKey(const ValueKey('swipe-favorite-background')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('swipe-delete-action')), findsNothing);
    expect(find.byKey(const ValueKey('swipe-favorite-action')), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.star_border_rounded), findsNothing);
  });

  testWidgets('a left reveal does not delete until its action is tapped', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final repository = SwipeTestRepository([_note(1)]);
    final store = NotesStore(repository);
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    await _dragNote(tester, 1, const Offset(-180, 0));

    expect(_translation(tester, 1), -348);
    expect(store.notes, hasLength(1));
    expect(await repository.getNotes(), hasLength(1));
    expect(find.byKey(const ValueKey('swipe-delete-action')), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('swipe-delete-background')))
          .width,
      348,
    );

    await tester.tap(find.byKey(const ValueKey('swipe-delete-action')));
    await tester.pumpAndSettle();

    expect(store.notes, isEmpty);
    expect(await repository.getNotes(), isEmpty);
  });

  testWidgets('a right reveal does not favorite until its action is tapped', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final repository = SwipeTestRepository([_note(1)]);
    final store = NotesStore(repository);
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    await _dragNote(tester, 1, const Offset(90, 0));

    final foreground = find.byKey(const ValueKey('swipe-translation-1'));
    expect(_translation(tester, 1), 85);
    expect(tester.getSize(foreground).width, 348);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('swipe-favorite-background')))
          .width,
      85,
    );
    expect(store.notes.single.isFavorite, isFalse);
    expect((await repository.getNotes()).single.isFavorite, isFalse);
    expect(find.byKey(const ValueKey('swipe-favorite-action')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('swipe-favorite-action')));
    await tester.pumpAndSettle();

    expect(store.notes.single.isFavorite, isTrue);
    expect((await repository.getNotes()).single.isFavorite, isTrue);
    expect(_translation(tester, 1), 0);
  });

  testWidgets('a below-threshold drag settles closed without an action', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final store = NotesStore(SwipeTestRepository([_note(1)]));
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    await _dragNote(tester, 1, const Offset(-40, 0));

    expect(_translation(tester, 1), 0);
    expect(store.notes, hasLength(1));
    expect(store.notes.single.isFavorite, isFalse);
    expect(find.byKey(const ValueKey('swipe-delete-action')), findsNothing);
  });

  testWidgets('opening one row closes the previously revealed row', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final store = NotesStore(SwipeTestRepository([_note(1), _note(2)]));
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    await _dragNote(tester, 1, const Offset(-180, 0));
    expect(_translation(tester, 1), -348);
    await _dragNote(tester, 2, const Offset(90, 0));

    expect(_translation(tester, 1), 0);
    expect(_translation(tester, 2), 85);
  });

  testWidgets('a canceled drag and vertical drag leave the list usable', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final store = NotesStore(
      SwipeTestRepository(List.generate(20, (index) => _note(index + 1))),
    );
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('swipe-note-20'))),
    );
    await gesture.moveBy(const Offset(-80, 0));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(_translation(tester, 20), 0);

    await tester.drag(
      find.byKey(const ValueKey('swipe-note-20')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setReferenceSize(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(393, 852));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _dragNote(WidgetTester tester, int id, Offset offset) async {
  await tester.timedDrag(
    find.byKey(ValueKey('swipe-note-$id')),
    offset,
    const Duration(milliseconds: 400),
  );
  await tester.pumpAndSettle();
}

double _translation(WidgetTester tester, int id) {
  return tester
      .widget<Transform>(find.byKey(ValueKey('swipe-translation-$id')))
      .transform
      .storage[12];
}

Widget _home(NotesStore store) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: HomePage(store: store),
  );
}

Note _note(int id, {String? title}) {
  final timestamp = DateTime(2026, 1, id);
  return Note(
    id: id,
    title: title ?? 'Note $id',
    body: '',
    color: NoteColor.magenta,
    isFavorite: false,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
