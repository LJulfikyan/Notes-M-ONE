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

Use one class per Dart file.

Do not place multiple implementation classes in the same file. Each class should have its own snake_case file matching the class responsibility. Keep enums, extensions, and other reusable declarations separate rather than collecting unrelated declarations into large files.

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

## Design traps

1. Brief requires plain text, but Figma visually italicizes a paragraph.
2. Formatting toolbar suggests rich text although rich text is explicitly forbidden.
3. Favorite state uses outline stars in list/filter views but a filled yellow star in frame 11.
4. Editor frames 09/10 show an eye control where frame 11 shows a star.
5. Search has no explicit close control; X is interpreted as clear query.
6. Empty search-query behavior is unspecified; match frame 07 with blank results.
7. `"File not found"` is file-browser terminology in a Notes app; preserve for fidelity and document it.
8. Save and discard dialog trigger semantics are not defined.
9. Explicit save semantics conflict with the process-kill requirement unless drafts are persisted separately.
10. FAB overlays list content in the fixed design; implementation must add bottom scroll space.
11. Note colors are shown but no color-selection UI or assignment rule exists.
12. Frame 14's blue outline is Figma selection chrome, not part of the app.

These are not reasons to redesign the app. Make the smallest coherent implementation and document the assumption/deviation.

## Chosen interaction semantics

- card tap -> reader
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

## UI restrictions

No third-party visual component packages.
Do not use `Dismissible`.

The custom swipe implementation is high-value code. It must:
- distinguish horizontal intent from vertical scrolling;
- support cancellation/reversal;
- use threshold and/or velocity intentionally;
- settle cleanly after interruption;
- not lose data or accidentally trigger both actions.

Use the exact supplied illustrations rather than approximations.
The current presentation uses compact rounded cards and controls, a small
purple FAB, responsive illustration sizing, and a compact confirmation dialog
with dark surface plus red/green actions. Treat these as implementation choices
informed by the rendered overview, not extracted exact Figma measurements.

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

The current matrix uses 320×720, 390×720, and 768×720 logical viewports with
text scales 0.9, 1.0, and 1.5. Preserve or update it whenever the home layout
changes. Focused tests also exercise draft lifecycle flushing, confirmation
outcomes, persisted favorite/delete actions, search/filter behavior, and swipe
cancellation/disposal.

Always run `flutter analyze` and the full test suite before concluding a task.

## Modification discipline

Do not broaden a task unnecessarily. If a prompt asks for one feature, complete and validate that feature, summarize any issue, and stop.
