import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/presentation/pages/home_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

import 'support/swipe_test_repository.dart';

void main() {
  testWidgets('below-threshold swipes snap back without an action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = NotesStore(SwipeTestRepository([_note(1)]));

    await tester.pumpWidget(_home(store));
    await tester.pump();
    await tester.drag(
      find.byKey(const ValueKey('swipe-note-1')),
      const Offset(-60, 0),
    );
    await tester.pumpAndSettle();

    expect(store.notes, hasLength(1));
    expect(store.notes.single.isFavorite, isFalse);
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('swipe-translation-1')))
          .transform
          .storage[12],
      0,
    );
  });

  testWidgets('right swipe commits and persists the favorite toggle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = SwipeTestRepository([_note(1)]);
    final store = NotesStore(repository);

    await tester.pumpWidget(_home(store));
    await tester.pump();
    await tester.drag(
      find.byKey(const ValueKey('swipe-note-1')),
      const Offset(300, 0),
    );
    await tester.pump();
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('swipe-translation-1')))
          .transform
          .storage[12],
      greaterThan(0),
    );
    await tester.pumpAndSettle();
    await tester.pump();

    expect(store.notes.single.isFavorite, isTrue);
    expect((await repository.getNotes()).single.isFavorite, isTrue);
  });

  testWidgets('left swipe commits and persists deletion', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = SwipeTestRepository([_note(1)]);
    final store = NotesStore(repository);

    await tester.pumpWidget(_home(store));
    await tester.pump();
    await tester.drag(
      find.byKey(const ValueKey('swipe-note-1')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    await tester.pump();

    expect(store.notes, isEmpty);
    expect(await repository.getNotes(), isEmpty);
  });

  testWidgets('vertical drags continue to scroll the notes list', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final store = NotesStore(
      SwipeTestRepository(List.generate(12, (index) => _note(index + 1))),
    );

    await tester.pumpWidget(_home(store));
    await tester.pump();
    await tester.drag(
      find.byKey(const ValueKey('swipe-note-1')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
  });
}

Widget _home(NotesStore store) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: HomePage(store: store),
  );
}

Note _note(int id) {
  final timestamp = DateTime(2026, 1, id);
  return Note(
    id: id,
    title: 'Note $id',
    body: '',
    color: NoteColor.magenta,
    isFavorite: false,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
