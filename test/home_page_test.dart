import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/data/notes_repository.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/domain/note_draft.dart';
import 'package:notes_m_one/features/notes/presentation/pages/home_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';

void main() {
  testWidgets('renders the empty home at narrow and wide widths', (
    tester,
  ) async {
    for (final width in [320.0, 680.0]) {
      await tester.binding.setSurfaceSize(Size(width, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_home([], ValueKey(width)));
      await tester.pump();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Create your first note !'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    }
  });

  testWidgets('renders flexible cards and filters at narrow and wide widths', (
    tester,
  ) async {
    final notes = [
      _note(
        id: 1,
        title:
            'A long note title that should naturally wrap without overflowing the card',
        color: NoteColor.pink,
      ),
      _note(
        id: 2,
        title: 'Favorite note',
        color: NoteColor.green,
        isFavorite: true,
      ),
    ];

    for (final width in [320.0, 680.0]) {
      await tester.binding.setSurfaceSize(Size(width, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_home(notes, ValueKey(width)));
      await tester.pump();

      expect(find.text(notes.first.title), findsOneWidget);
      expect(find.text('Favorite note'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Show filters'));
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);

      await tester.tap(find.text('Favorites'));
      await tester.pump();
      expect(find.text('Favorite note'), findsOneWidget);
      expect(find.text(notes.first.title), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}

Widget _home(List<Note> notes, Key key) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: HomePage(key: key, store: NotesStore(_HomeRepository(notes))),
  );
}

class _HomeRepository implements NotesRepository {
  _HomeRepository(this._notes);

  final List<Note> _notes;

  @override
  Future<Note> createNote({
    required String title,
    required String body,
    NoteColor? color,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteDraft(String id) => throw UnimplementedError();

  @override
  Future<void> deleteNote(int id) => throw UnimplementedError();

  @override
  Future<NoteDraft?> getDraft(String id) => throw UnimplementedError();

  @override
  Future<List<Note>> getNotes() async => List.of(_notes);

  @override
  Future<NoteColor> reserveNextColor() => throw UnimplementedError();

  @override
  Future<void> saveDraft(NoteDraft draft) => throw UnimplementedError();

  @override
  Future<Note> toggleFavorite(Note note) => throw UnimplementedError();

  @override
  Future<Note> updateNote(Note note) => throw UnimplementedError();
}

Note _note({
  required int id,
  required String title,
  required NoteColor color,
  bool isFavorite = false,
}) {
  final timestamp = DateTime(2026, 1, id);
  return Note(
    id: id,
    title: title,
    body: 'A sufficiently long body belongs in the reader, not the home card.',
    color: color,
    isFavorite: isFavorite,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
