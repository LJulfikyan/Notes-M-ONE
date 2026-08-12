# Architecture Plan

Keep this smaller than a typical production app.

## Dependency direction

```text
Flutter pages/widgets
        |
        v
MobX NotesStore
        |
        v
NotesRepository
        |
        v
SQLite
```

No UI code should know SQL.

## Suggested structure

```text
lib/
  main.dart
  app.dart

  core/
    theme/
      app_colors.dart
      app_theme.dart

  features/
    notes/
      domain/
        note.dart
        note_color.dart
        note_draft.dart

      data/
        notes_database.dart
        notes_repository.dart
        sqlite_notes_repository.dart

      presentation/
        stores/
          notes_store.dart
          notes_store.g.dart

        pages/
          home_page.dart
          search_page.dart
          note_editor_page.dart
          note_reader_page.dart

        widgets/
          note_card.dart
          swipe_note_tile.dart
          note_filter_bar.dart
          empty_notes_view.dart
          no_search_results_view.dart
          editor_toolbar.dart
```

This is a guide, not a requirement to create empty files up front. Create files only when the task needs them.

## State

`NotesStore` should own:
- observable note collection;
- selected filter;
- search query;
- loading/error state if needed;
- actions for load/create/update/delete/favorite;
- computed visible/search results.

Do not store `BuildContext` or navigation state in the store.

## Persistence

SQLite should persist:
- notes;
- editor draft(s);
- only the minimum metadata required.

Keep schema migrations simple but explicit.

## Draft model

A draft needs enough information to restore editing without mutating the committed note:
- draft key / note id if editing
- title
- body
- favorite/current presentation state if needed
- color for new note
- timestamp

A small debounce before writing drafts is acceptable; flush on important lifecycle/navigation boundaries where practical.

## Navigation

Use Flutter's built-in `Navigator`.

Expected routes/screens:
- home
- search
- editor(new)
- editor(existing)
- reader(existing)

Do not add a routing dependency solely for this challenge.

## UI assets

Copy the 2000px extracted illustrations into a normal Flutter asset directory during bootstrap:
- empty notes
- no search results

The `.codex_reference/` directory remains local-only and ignored.

## Testing

Prefer:
- repository/store unit tests;
- focused widget tests;
- responsive/text-scale matrix tests for list states;
- custom swipe behavior tests where stable.

Avoid brittle pixel-perfect tests until core behavior is stable.
