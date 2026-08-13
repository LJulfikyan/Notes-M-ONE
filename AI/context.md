# AI Context — M-One Notes Challenge

This is the real working brief for assistants modifying this repository. Keep it synchronized with the implementation as the project evolves.

## Goal

Build the supplied Flutter Notes UI as a small shipped-quality application, not a disposable prototype. Local persistence, robust gestures, responsive layout, process-kill resilience, and explicit handling of design gaps matter as much as visual resemblance.

## Scope

Implement design frames 01–14, choosing **06 Filter View** instead of 05 Favorites List.

In scope:
- empty home
- populated home
- custom swipe-to-delete
- custom swipe-to-favorite
- All / Favorites / Recent filter view
- search and no-results state
- new/edit note editor
- editor favorite state
- save and discard confirmations
- reading note
- local persistence
- meaningful responsive/tests work

Out of scope:
- backend
- sync
- auth
- tags
- folders
- rich text
- markdown
- design-system work

## Architecture contract

### File organization rule

Use **one primary implementation concept per file**.

A `StatefulWidget` and its private `State` class belong in the same Dart file;
the private State is part of the widget's implementation, not an independent
concept. Keep independent reusable widgets, stores, repositories, models,
services, and extensions in their own snake_case files. Small private enums or
helpers used only by one widget may remain with that widget.

Keep the codebase small:

`UI -> MobX NotesStore -> NotesRepository -> SQLite`

UI must not call SQLite directly.

Use MobX for observable application state and computed filtered/search views. Use SQLite for durable note and draft persistence. Do not add a second state-management framework.

Use built-in Flutter navigation unless a concrete implementation problem requires otherwise.

`NotesApp` creates one `NotesStore` backed by `SqliteNotesRepository` and
`NotesDatabase`; `HomePage` loads that store. Home/search cards push the reader,
and the reader pushes the editor. Keep this wiring direct rather than adding a
routing or dependency-injection layer.

## Data model

Saved notes are plain text:
- `id`
- `title`
- `body`
- `color`
- `isFavorite`
- `createdAt`
- `updatedAt`

No formatting spans or document model.

Palette:
- `#FD99FF`
- `#FF9E9E`
- `#91F48F`
- `#FFF599`
- `#9EFFFF`
- `#B69CFF`

New notes cycle through the palette; color is stored with the note and does not change because of reorder/delete/filter operations.

## Draft safety

A dirty editor must persist a draft separately from the saved note. A process kill must not destroy typed content.

Save:
- writes/promotes the draft to the saved note;
- updates `updatedAt`;
- clears the draft.

Discard:
- clears the draft;
- leaves the saved note unchanged.

Avoid a complicated autosave architecture; use a small debounced draft write.
Draft writes must be serialized so an older asynchronous write cannot overwrite
newer text. Flush the current dirty draft when the app becomes inactive, paused,
or detached, and when the editor is disposed. Save and discard must wait for
already-queued writes before clearing the draft, otherwise a late write can
resurrect discarded content.

## Design sources

Local-only source material is in `.codex_reference/`:
- `overview.png` — all 14 frames; primary visual reference.
- `challenge.pdf` — original task.
- `design.fig` — original native Figma file.
- `figma_thumbnail.png` — rendered Figma thumbnail.
- `assets/empty_notes_*.png` — exact empty-state illustration exports.
- `assets/search_no_results_*.png` — exact no-results illustration exports.
- `assets_sheet.jpg` — extracted image inventory.
- device reference JPEGs — embedded source references, not app runtime assets.

Reference priority for visual work:

1. `.codex_reference/overview.png`
2. extracted illustration assets
3. `.codex_reference/figma_thumbnail.png`
4. `docs/DESIGN_REFERENCE.md`
5. native `.codex_reference/design.fig` only when a real parser is available

Do **not** assume native `.fig` binary node properties are readable. If you cannot actually parse the Figma node tree, use the rendered references and documented extracted colors. Never fabricate exact measurements/fonts/vector paths.

Known verified colors from the rendered Figma data:
- app background `#252525`
- note magenta `#FD99FF`
- note pink `#FF9E9E`
- note green `#91F48F`
- note yellow `#FFF599`
- note cyan `#9EFFFF`
- note purple `#B69CFF`
- delete action `#FF0000`
- favorite swipe action `#FFD700`
- common dark surface `#454545`
- another common control surface `#3B3B3B`

## Typography

Nunito is bundled locally as the application-wide font; do not use
platform-default fonts. The bundled variable font supplies the 300, 400, 600,
and 700 weights used by the verified styles. Graphical `IconData` must continue
to render through `Icon`, not through Nunito text. Exact known Figma styles are
documented in `docs/REFERENCE_GEOMETRY.md`; retain existing sizes and weights
for typography that has not been measured directly.

## Design traps

1. Brief requires plain text, but Figma visually italicizes a paragraph.
2. Formatting toolbar suggests rich text although rich text is explicitly forbidden.
3. Favorite star treatment and color vary between list, swipe, and editor frames.
4. Editor frames 09/10 show an eye control where frame 11 shows a star.
5. Search has no explicit close control; X is interpreted as clear query.
6. Empty search-query behavior is unspecified; match frame 07 with blank results.
7. `"File not found"` is file-browser terminology in a Notes app; preserve for fidelity and document it.
8. Save and discard dialog trigger semantics are not defined.
9. Explicit save semantics conflict with the process-kill requirement unless drafts are persisted separately.
10. FAB overlays list content in the fixed design; implementation must add bottom scroll space.
11. Note colors are shown but no color-selection UI or assignment rule exists.
12. Frame 14's blue outline is Figma selection chrome, not part of the app.
13. Frame 06 has no specified entry action and is not connected to Info.

These are not reasons to redesign the app. Make the smallest coherent implementation and document the assumption/deviation.

## Chosen interaction semantics

- card tap -> reader
- an open swipe foreground tap closes the row first; the next closed-row tap
  may open the reader
- FAB -> new editor
- swipe left -> delete
- swipe right -> favorite toggle
- filter choice -> All / Favorites / Recent
- Recent -> sort all notes by `updatedAt` descending
- search X -> clear
- system/back -> exit search
- dirty editor Back -> discard dialog
- clean editor Back -> pop
- dirty editor Save -> save dialog
- saved note stays unchanged until confirmed Save
- favorite is principally toggled from the home swipe interaction
- populated Home always shows All / Favorites / Recent; Info remains inert
- Editor Edit and Preview are modes of the same route; Preview renders the
  current unsaved draft, and Preview Back returns to Edit

## UI restrictions

No third-party visual component packages.
Do not use `Dismissible`.

The custom swipe implementation is high-value code. It must:
- distinguish horizontal intent from vertical scrolling;
- support cancellation/reversal;
- use threshold and/or velocity intentionally;
- settle cleanly after interruption;
- not lose data or accidentally trigger both actions.

Swipe actions are reveal-then-tap interactions, never automatic actions.
Favorite reveals about 85 logical pixels of yellow on the left while retaining
and translating the full-width foreground. At full favorite reveal, the
foreground's left corners are square while its right corners remain rounded.
Delete moves the foreground fully left to expose a complete red row. No action
layer may show at rest, and opening one row closes the previous row.

Note cards retain the full list width, use `EdgeInsets.all(28)`, and derive
their height from naturally wrapped Nunito text. Favorite cards include a
noninteractive outline-star indicator with reserved text space. Swipe action
backgrounds always match the card's dynamic height.

Shared header/action controls are 50×50 with radius 15 and 24×24 graphical
icons. Press feedback remains clipped to the visible rounded control.

Use the supplied illustration assets rather than approximations. The final
presentation uses a 66-pixel purple FAB, responsive illustration sizing, and a
compact confirmation dialog with dark surface plus red/green actions. Treat
values documented as approximate in `docs/REFERENCE_GEOMETRY.md` as rendered
reference estimates rather than native Figma metadata.

## Testing priority

Prefer a few meaningful tests over token coverage.

High-value tests:
- list renders without overflow across multiple widths;
- list renders under larger text scales and long content;
- empty/populated/filter/search states;
- favorite/delete persistence;
- draft survives store/repository recreation;
- save/discard semantics;
- custom swipe threshold and interrupted settle behavior where practical.

The responsive home widget test should cover empty and populated states at
narrow, normal-phone, and wide widths, with more than one text scale and long
plain-text title/body input. Assert there are no captured framework exceptions
or overflow errors rather than relying on a token pump.

The current matrix uses 320×720, 393×720, and 768×720 logical viewports with
text scales 0.9, 1.0, and 1.5. Preserve or update it whenever the home layout
changes. Focused tests also exercise draft lifecycle flushing, confirmation
outcomes, persisted favorite/delete actions, search/filter behavior, and swipe
cancellation/disposal. At submission finalization, `flutter test` reports 68
passing tests.

Before concluding an implementation task, run:

```bash
dart format .
flutter analyze
flutter test
git diff --check
```

Do not introduce another state-management framework, direct UI-to-SQL access,
rich text/markdown state, a UI/design-system package, `Dismissible`, backend
features, sync, auth, tags, folders, or undocumented product scope.

## Modification discipline

Do not broaden a task unnecessarily. If a prompt asks for one feature, complete and validate that feature, summarize any issue, and stop.
