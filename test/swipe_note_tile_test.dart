import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/home_page.dart';
import 'package:notes_m_one/features/notes/presentation/pages/note_reader_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('a closed Home note opens the reader for that exact note', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final target = _note(
      1,
      title: 'Target note',
      body: 'Target body belongs to note one.',
    );
    final store = NotesStore(
      SwipeTestRepository([
        target,
        _note(2, title: 'Different note', body: 'Different body.'),
      ]),
    );
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    final cardRect = tester.getRect(
      find.byKey(const ValueKey('swipe-translation-1')),
    );
    await tester.tapAt(Offset(cardRect.right - 16, cardRect.bottom - 16));
    await tester.pumpAndSettle();

    final reader = tester.widget<NoteReaderPage>(find.byType(NoteReaderPage));
    expect(reader.note.id, target.id);
    expect(find.text(target.title), findsOneWidget);
    expect(find.text(target.body), findsOneWidget);
  });

  testWidgets('a Favorites result opens its exact note in the reader', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final favorite = _note(
      1,
      title: 'Favorite target',
      body: 'Favorite reader body.',
      isFavorite: true,
    );
    final store = NotesStore(
      SwipeTestRepository([
        favorite,
        _note(2, title: 'Ordinary note', body: 'Not the target.'),
      ]),
    );
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(favorite.title));
    await tester.pumpAndSettle();

    final reader = tester.widget<NoteReaderPage>(find.byType(NoteReaderPage));
    expect(reader.note.id, favorite.id);
    expect(find.text(favorite.body), findsOneWidget);
  });

  testWidgets('a Recent result opens its exact note in the reader', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final recent = _note(
      1,
      title: 'Recently updated target',
      body: 'Recent reader body.',
      updatedAt: DateTime(2026, 3, 1),
    );
    final store = NotesStore(
      SwipeTestRepository([
        recent,
        _note(
          2,
          title: 'Older update',
          body: 'Older body.',
          updatedAt: DateTime(2026, 2, 1),
        ),
      ]),
    );
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(recent.title));
    await tester.pumpAndSettle();

    final reader = tester.widget<NoteReaderPage>(find.byType(NoteReaderPage));
    expect(reader.note.id, recent.id);
    expect(find.text(recent.body), findsOneWidget);
  });

  testWidgets('a short note is closed and its foreground fills the row', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final store = NotesStore(SwipeTestRepository([_note(1, title: 'Short')]));
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    final foreground = find.byKey(const ValueKey('swipe-translation-1'));
    expect(tester.getSize(foreground).width, 348);
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

  testWidgets('favorite reveal squares only the foreground left corners', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final store = NotesStore(SwipeTestRepository([_note(1)]));
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    final closedRadius = _foregroundRadius(tester, 1);
    expect(closedRadius.topLeft.x, 6);
    expect(closedRadius.bottomLeft.x, 6);
    expect(closedRadius.topRight.x, 6);
    expect(closedRadius.bottomRight.x, 6);

    await _dragNote(tester, 1, const Offset(90, 0));

    final favoriteOpenRadius = _foregroundRadius(tester, 1);
    expect(favoriteOpenRadius.topLeft, Radius.zero);
    expect(favoriteOpenRadius.bottomLeft, Radius.zero);
    expect(favoriteOpenRadius.topRight.x, closedRadius.topRight.x);
    expect(favoriteOpenRadius.bottomRight.x, closedRadius.bottomRight.x);
  });

  testWidgets('swipe backgrounds follow short and multiline card heights', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final store = NotesStore(
      SwipeTestRepository([
        _note(1, title: 'Short'),
        _note(
          2,
          title:
              'A deliberately long note title that wraps naturally across several lines',
        ),
      ]),
    );
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    await _dragNote(tester, 1, const Offset(90, 0));
    final shortForegroundHeight = tester
        .getSize(find.byKey(const ValueKey('swipe-translation-1')))
        .height;
    expect(
      tester
          .getSize(find.byKey(const ValueKey('swipe-favorite-background')))
          .height,
      shortForegroundHeight,
    );

    await _dragNote(tester, 2, const Offset(-180, 0));
    final multilineForegroundHeight = tester
        .getSize(find.byKey(const ValueKey('swipe-translation-2')))
        .height;
    expect(multilineForegroundHeight, greaterThan(shortForegroundHeight));
    expect(
      tester
          .getSize(find.byKey(const ValueKey('swipe-delete-background')))
          .height,
      multilineForegroundHeight,
    );
    expect(tester.takeException(), isNull);
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

  testWidgets('a normal tap works after a partial swipe snaps closed', (
    tester,
  ) async {
    await _setReferenceSize(tester);
    final note = _note(1, title: 'Partial swipe note', body: 'Reader body.');
    final store = NotesStore(SwipeTestRepository([note]));
    await tester.pumpWidget(_home(store));
    await tester.pumpAndSettle();

    await _dragNote(tester, 1, const Offset(-40, 0));
    expect(_translation(tester, 1), 0);

    await tester.tap(find.text(note.title));
    await tester.pumpAndSettle();

    final reader = tester.widget<NoteReaderPage>(find.byType(NoteReaderPage));
    expect(reader.note.id, note.id);
  });

  testWidgets(
    'an open foreground tap closes first and the next tap opens the reader',
    (tester) async {
      await _setReferenceSize(tester);
      final note = _note(1, title: 'Revealed note', body: 'Reader body.');
      final store = NotesStore(SwipeTestRepository([note]));
      await tester.pumpWidget(_home(store));
      await tester.pumpAndSettle();

      await _dragNote(tester, 1, const Offset(90, 0));
      expect(_translation(tester, 1), 85);

      await tester.tap(find.text(note.title));
      await tester.pumpAndSettle();

      expect(_translation(tester, 1), 0);
      expect(find.byType(NoteReaderPage), findsNothing);
      expect(store.notes.single.isFavorite, isFalse);

      await tester.tap(find.text(note.title));
      await tester.pumpAndSettle();

      final reader = tester.widget<NoteReaderPage>(find.byType(NoteReaderPage));
      expect(reader.note.id, note.id);
    },
  );

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

BorderRadius _foregroundRadius(WidgetTester tester, int id) {
  final material = find.descendant(
    of: find.byKey(ValueKey('swipe-translation-$id')),
    matching: find.byType(Material),
  );
  return tester.widget<Material>(material).borderRadius! as BorderRadius;
}

Widget _home(NotesStore store) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: HomePage(store: store),
  );
}

Note _note(
  int id, {
  String? title,
  String body = '',
  bool isFavorite = false,
  DateTime? updatedAt,
}) {
  final timestamp = DateTime(2026, 1, id);
  return Note(
    id: id,
    title: title ?? 'Note $id',
    body: body,
    color: NoteColor.magenta,
    isFavorite: isFavorite,
    createdAt: timestamp,
    updatedAt: updatedAt ?? timestamp,
  );
}
