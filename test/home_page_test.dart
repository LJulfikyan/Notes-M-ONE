import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/core/theme/app_theme.dart';
import 'package:notes_m_one/features/notes/domain/note.dart';
import 'package:notes_m_one/features/notes/domain/note_color.dart';
import 'package:notes_m_one/features/notes/domain/note_filter.dart';
import 'package:notes_m_one/features/notes/presentation/pages/home_page.dart';
import 'package:notes_m_one/features/notes/presentation/pages/search_page.dart';
import 'package:notes_m_one/features/notes/presentation/stores/notes_store.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/contained_icon_button.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/header_button.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/note_filter_chip.dart';
import 'package:notes_m_one/features/notes/presentation/widgets/notes_info_dialog.dart';

import 'support/counting_navigator_observer.dart';
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
        expect(find.byType(NoteFilterChip), findsNothing);
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

    expect(
      Theme.of(
        tester.element(find.byType(HomePage)),
      ).textTheme.bodyMedium?.fontFamily,
      'Nunito',
    );

    final illustrationRect = tester.getRect(
      find.byKey(const ValueKey('empty-notes-illustration')),
    );
    expect(illustrationRect.width, closeTo(320, 1));
    expect(illustrationRect.height, closeTo(262.4, 1));
    expect(illustrationRect.left, closeTo(37, 1));
    expect(illustrationRect.top, closeTo(279, 1));
    final captionRect = tester.getRect(find.text('Create your first note !'));
    expect(captionRect.top - illustrationRect.bottom, closeTo(19, 1));
    final caption = tester.widget<Text>(find.text('Create your first note !'));
    expect(caption.style?.fontFamily, 'Nunito');
    expect(caption.style?.fontSize, 20);
    expect(caption.style?.fontWeight, FontWeight.w300);
    expect(captionRect.left, greaterThanOrEqualTo(0));
    expect(captionRect.right, lessThanOrEqualTo(393));
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
    expect(searchRect.size, const Size.square(50));
    expect(infoRect.size, const Size.square(50));
    expect(infoRect.left - searchRect.right, 19);
    final searchControl = tester.widget<ContainedIconButton>(controls.at(0));
    expect(searchControl.size, 50);
    expect(searchControl.iconSize, 24);
    expect(searchControl.borderRadius, BorderRadius.circular(15));
    expect(
      tester.getSize(find.byIcon(Icons.search_rounded)),
      const Size.square(24),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.titleTextStyle?.fontFamily, 'Nunito');
    expect(appBar.titleTextStyle?.fontSize, 43);
    expect(appBar.titleTextStyle?.fontWeight, FontWeight.w600);
    expect(tester.getRect(find.text('Notes')).right, lessThan(searchRect.left));

    final noteRect = tester.getRect(find.byType(NoteCard));
    expect(noteRect.left, 23);
    expect(noteRect.width, 348);
    final cardPadding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(NoteCard),
        matching: find.byType(Padding),
      ),
    );
    expect(cardPadding.padding, const EdgeInsets.all(28));
    final noteText = tester.widget<Text>(find.text('Short'));
    expect(noteText.style?.fontFamily, 'Nunito');
    expect(noteText.style?.fontSize, 25);
    expect(noteText.style?.fontWeight, FontWeight.w400);
    expect(noteText.style?.height, 1);
    expect(
      tester.getSize(find.byType(FloatingActionButton)),
      const Size.square(66),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('note cards grow from their naturally wrapped text', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(393, 852));
    const shortTitle = 'Short';
    const longTitle =
        'A deliberately long note title that wraps naturally across several lines';
    await tester.pumpWidget(
      _home([
        _note(id: 1, title: shortTitle, body: '', color: NoteColor.yellow),
        _note(id: 2, title: longTitle, body: '', color: NoteColor.cyan),
      ], 1),
    );
    await tester.pumpAndSettle();

    final shortCard = find.byKey(const ValueKey('swipe-translation-1'));
    final longCard = find.byKey(const ValueKey('swipe-translation-2'));
    expect(
      tester.getSize(shortCard).height,
      lessThan(tester.getSize(longCard).height),
    );
    expect(tester.widget<Text>(find.text(longTitle)).maxLines, isNull);
    expect(tester.widget<Text>(find.text(longTitle)).overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorite cards show a reserved outline-star indicator', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(393, 852));
    const favoriteTitle =
        'A long favorite note title that wraps naturally without crossing its indicator';
    await tester.pumpWidget(
      _home([
        _note(id: 1, title: 'Ordinary note', body: '', color: NoteColor.yellow),
        _note(
          id: 2,
          title: favoriteTitle,
          body: '',
          color: NoteColor.green,
          isFavorite: true,
        ),
      ], 1),
    );
    await tester.pumpAndSettle();

    final favoriteIndicator = find.byKey(
      const ValueKey('note-card-favorite-2'),
    );
    expect(favoriteIndicator, findsOneWidget);
    expect(find.byKey(const ValueKey('note-card-favorite-1')), findsNothing);
    expect(
      tester.widget<Icon>(favoriteIndicator).icon,
      Icons.star_border_rounded,
    );
    final favoriteCardRect = tester.getRect(
      find.byKey(const ValueKey('swipe-translation-2')),
    );
    final favoriteTextRect = tester.getRect(find.text(favoriteTitle));
    final indicatorRect = tester.getRect(favoriteIndicator);
    expect(favoriteCardRect.right - indicatorRect.right, 28);
    expect(favoriteTextRect.right, lessThanOrEqualTo(indicatorRect.left - 12));
    expect(favoriteTextRect.height, greaterThan(25));
    expect(tester.widget<Text>(find.text(favoriteTitle)).maxLines, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reference filter controls stay left aligned', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      _home([_note(id: 1, title: 'Note', body: '', color: NoteColor.cyan)], 1),
    );
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
    final selectedStyle = tester.widget<Text>(find.text('All')).style!;
    expect(selectedStyle.fontFamily, 'Nunito');
    expect(selectedStyle.fontWeight, FontWeight.w700);
    expect(selectedStyle.fontSize, 16);
    expect(selectedStyle.height, 1);
    expect(selectedStyle.letterSpacing, 0);
    final unselectedStyle = tester.widget<Text>(find.text('Favorites')).style!;
    expect(unselectedStyle.fontFamily, 'Nunito');
    expect(unselectedStyle.fontWeight, FontWeight.w600);
    expect(unselectedStyle.fontSize, 16);
    expect(unselectedStyle.height, 1);
    expect(unselectedStyle.letterSpacing, 0);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Info opens instructions without changing filter or page', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(393, 852));
    final note = _note(
      id: 1,
      title: 'Favorite note',
      body: '',
      color: NoteColor.green,
      isFavorite: true,
    );
    final store = NotesStore(SwipeTestRepository([note]));
    final observer = CountingNavigatorObserver();
    await tester.pumpWidget(_homeWithStore(store, observers: [observer]));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(store.filter, NoteFilter.favorites);
    expect(observer.pagePushCount, 1);

    await tester.tap(find.bySemanticsLabel('Info'));
    await tester.pumpAndSettle();

    expect(find.byType(NotesInfoDialog), findsOneWidget);
    expect(find.byKey(const ValueKey('notes-info-title')), findsOneWidget);
    expect(
      find.textContaining('Notes are stored locally on this device.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Swipe right to reveal Favorite.'),
      findsOneWidget,
    );
    expect(find.textContaining('Swipe left to reveal Delete.'), findsOneWidget);
    expect(
      find.textContaining('Use All, Favorites, and Recent to filter notes.'),
      findsOneWidget,
    );
    expect(find.text('Got it'), findsOneWidget);
    expect(store.filter, NoteFilter.favorites);
    expect(observer.pagePushCount, 1);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SearchPage), findsNothing);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.byType(NotesInfoDialog), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    expect(store.filter, NoteFilter.favorites);
    expect(observer.pagePushCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Info closes with platform Back at increased text scale', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 720));
    final store = NotesStore(SwipeTestRepository([]));
    await tester.pumpWidget(_homeWithStore(store, textScale: 1.5));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Info'));
    await tester.pumpAndSettle();
    expect(find.byType(NotesInfoDialog), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(NotesInfoDialog), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
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
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Favorite note'), findsOneWidget);
    expect(find.byKey(const ValueKey('note-card-favorite-2')), findsOneWidget);
    expect(find.text(notes.first.title), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _home(List<Note> notes, double textScale) {
  return _homeWithStore(
    NotesStore(SwipeTestRepository(notes)),
    textScale: textScale,
  );
}

Widget _homeWithStore(
  NotesStore store, {
  double textScale = 1,
  List<NavigatorObserver> observers = const [],
}) {
  return MaterialApp(
    theme: AppTheme.dark,
    navigatorObservers: observers,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: HomePage(
        key: ValueKey('${store.hashCode}-$textScale'),
        store: store,
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
