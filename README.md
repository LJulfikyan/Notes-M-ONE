# Notes M-ONE

Flutter implementation of the M-One Notes challenge: a local-first notes app
with custom swipe actions, durable editor drafts, filters, search, reading, and
the supplied empty states.

> **Applying level:** TODO — fill this in before submission.

## Run

Prerequisite: a current stable Flutter SDK with an available iOS, Android,
macOS, or Chrome target.

```bash
flutter pub get
flutter run
```

Useful checks:

```bash
flutter analyze
flutter test
```

## Architecture and state management

The dependency direction is deliberately small:

```text
Flutter UI -> MobX NotesStore -> NotesRepository -> SQLite
```

MobX owns the observable note collection, selected filter, search query, and
derived list/search views. It fits this app because the reactive state is small
and the filtering/search computations stay close to their source state. SQLite
remains behind `NotesRepository`, so UI code never accesses storage directly.

## Persistence and drafts

Saved notes persist their title, body, color, favorite flag, and timestamps in
SQLite. New notes cycle through the supplied six-color palette; the assigned
color is stored on the note and is never inferred from list position.

Editing uses a separate SQLite draft rather than mutating the saved note.
Draft writes are debounced, serialized, and flushed when the app becomes
inactive, paused, detached, or when the editor is disposed. Confirming Save
promotes the content into the saved note and clears its draft. Discard clears
the draft and preserves the saved note.

## Frame choice and implemented behavior

The brief presents frames 05 and 06 as alternatives. This project implements
**06 — Filter View**, not a separate 05 Favorites List. `All`, `Favorites`, and
`Recent` are explicit filter modes. `Recent` means all notes sorted by
`updatedAt` descending; the reference does not define a time window.

Implemented states cover empty/populated home, custom left-delete and
right-favorite swipes, filters, blank/no-result search, new/edit note drafts,
save/discard confirmation, and reading. The editor toolbar is intentionally
static because the challenge requires plain-string note content rather than
rich text or markdown.

## Responsive and verification checks

The automated home widget matrix renders empty and populated states with long
titles/bodies at 320×720, 390×720, and 768×720 logical pixels, using text
scales 0.9, 1.0, and 1.5. It asserts that the framework reports no exceptions
or overflow errors. Focused tests also cover filters, search, draft recovery,
save/discard outcomes, persisted favorite/delete actions, and interrupted or
disposed swipe animations.

The app was additionally launched and visually checked on the iPhone 16 iOS
simulator at its default text setting during the final visual audit.

## What is still wrong with this

- A reader receives a snapshot of its note. If that note is edited from the
  reader, returning to the reader can still show the pre-edit text until the
  reader is reopened.
- The editor flushes drafts at lifecycle boundaries, but no mobile app can
  guarantee persistence for text entered immediately before an abrupt process
  kill that prevents the write from reaching SQLite.
- The source's exact font metadata and vector icon paths were not decoded from
  the native Figma binary. The app uses responsive Flutter typography and
  built-in icons that are visually close, rather than claiming exact matches.
- A destructive swipe has no undo or confirmation because the reference does
  not provide a recovery state.

## Design notes

The supplied design intentionally contains gaps and contradictions. These are
handled explicitly rather than silently redesigned:

- Notes remain plain `title`/`body` strings. The rich-text-looking paragraph
  styling and formatting toolbar therefore do not create formatting data.
- The design alternates between outline stars, a filled yellow star, and an eye
  in the editor. The implementation keeps the shown eye for non-favorites and
  filled yellow star for favorites without adding undocumented controls.
- The search X clears the query; system Back exits search. An empty query is
  blank, as in frame 07. The no-results copy remains `"File not found. Try
  searching again."` for visual fidelity even though it is file-browser
  terminology.
- Dirty Save opens the save/discard confirmation; dirty Back opens the
  discard/keep confirmation; clean Back pops immediately.
- The design provides no color picker, so new notes cycle through and persist
  the supplied palette. The fixed-frame FAB overlaps content visually, while
  the actual list includes bottom scroll padding so the final card remains
  reachable.
- Figma frame labels, the grey canvas, frame 14's blue selection outline, and
  the shown system keyboard are reference chrome rather than app UI.

## AI context

See [AI/context.md](AI/context.md) for the implementation brief, constraints,
and guidance for future changes.

## Manual submission task

Record the required unedited approximately three-minute screen recording of
yourself working on part of the project and talking through it. This repository
does not create that recording automatically.
