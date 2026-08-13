# AGENTS.md

## Project

This repository is the M-One Flutter Notes challenge. Build a small, production-quality local notes app that closely follows the supplied design while making deliberate decisions where the design is incomplete or contradictory.
For every UI task, `docs/VISUAL_ACCEPTANCE.md` is mandatory reading.
Its visual and interaction rules override default Material widget behavior.
For UI work, read `docs/REFERENCE_GEOMETRY.md`.
At the 393×852 reference viewport, its measured geometry is the visual
acceptance baseline. Do not substitute default Material dimensions.
Read these before changing code:
- `AI/context.md`
- `docs/CHALLENGE_SUMMARY.md`
- `docs/DESIGN_REFERENCE.md`
- `docs/DESIGN_NOTES_DRAFT.md`
- `docs/ARCHITECTURE.md`

Local design references are under `.codex_reference/`.

## Non-negotiable challenge rules

- Implement frames 01–14, except implement **06 Filter View** and do not implement 05 Favorites List as a separate solution.
- Notes contain plain-string `title` and `body`.
- No rich-text, markdown, or formatting data model.
- The editor formatting toolbar is static/decorative if rendered.
- Persist data locally.
- No backend, sync, auth, tags, folders, or design-system project.
- Do not use third-party packages to provide visual UI components.
- Do not use Flutter `Dismissible`.
- Custom horizontal swipe behavior must coexist cleanly with vertical scrolling.
- The app must be responsive and tolerate larger text scales and long content.
- Do not silently hide known design contradictions. Preserve or deliberately resolve them and document the decision.

## Architecture

## File/class rule

- Use one class per file.
- Do not declare multiple implementation classes in the same Dart file.
- Each class must live in a file named after that class using Dart snake_case naming.
- Small enums, typedefs, and extensions may have their own files as well; do not bundle unrelated declarations together for convenience.

Use a deliberately small architecture:

`Flutter UI -> MobX NotesStore -> NotesRepository -> SQLite`

Allowed non-visual dependencies:
- `mobx`
- `flutter_mobx`
- `mobx_codegen`
- `build_runner`
- `sqflite`
- `path`

Do not introduce Riverpod, Bloc, Provider, GetX, GoRouter, a DI package, Freezed, a generic clean-architecture framework, use-case/interactor layers, or a design-system package unless the task explicitly changes this decision.

Use built-in `Navigator` unless a concrete requirement makes that insufficient.

UI must not access SQLite directly.

## Domain rules

A saved note should contain, at minimum:
- id
- title
- body
- persisted note color
- favorite flag
- createdAt
- updatedAt

The note color palette is:

- magenta `#FD99FF`
- pink `#FF9E9E`
- green `#91F48F`
- yellow `#FFF599`
- cyan `#9EFFFF`
- purple `#B69CFF`

New notes receive colors automatically by cycling through this palette. The selected color is persisted on the note; never derive an existing note's color from its current list index.

Default list ordering: newest created first.
`Recent`: all notes ordered by `updatedAt` descending. This is an explicit design assumption and must remain documented.

## Draft/process-kill rule

Saved-note semantics and draft semantics are separate.

While editing:
- persist a draft locally without overwriting the saved note;
- saving promotes the draft into the saved note and clears the draft;
- discarding clears the draft;
- a process kill must not erase typed text.

Keep this implementation small. Do not add background sync or a complex undo/event architecture.

## Figma/reference rules

Priority:
1. `.codex_reference/overview.png`
2. extracted illustration assets
3. `.codex_reference/figma_thumbnail.png`
4. `docs/DESIGN_REFERENCE.md`
5. native `.codex_reference/design.fig` only when an actual parser is available

Do not invent "exact Figma values" that have not been extracted.

The bright blue border around frame 14 in the overview is a Figma selection indicator, not app UI.
The labels above frames are Figma frame names, not app UI.
The shown software keyboard is the system keyboard; never recreate it in Flutter.

Icons are not separate raster assets in the `.fig` archive. Do not assume a Material icon is exact merely because it is similar. Prefer built-in icons only when visually close enough; otherwise use a small `CustomPainter` or local vector/path implementation. Do not add an icon/UI package.

## Interaction decisions

- Home card tap -> Reading Note.
- FAB -> New Note editor.
- Swipe left -> delete action.
- Swipe right -> favorite/unfavorite.
- Search X -> clear the query.
- System/back navigation exits search.
- Empty search query shows the blank state drawn in frame 07.
- Preserve the Figma no-results copy `"File not found. Try searching again."` for visual fidelity, but document the terminology issue.
- Back from a dirty editor -> frame 13 discard confirmation.
- Back from a clean editor -> pop immediately.
- Save icon from a dirty editor -> frame 12 save confirmation.
- Nonfavorite editor shows the eye control from frames 09/10.
- Favorite editor shows the star state from frame 11. This inconsistency is documented; do not invent extra toolbar controls without need.

## UI quality

- Keep card text wrapping naturally.
- Avoid hard-coded screen heights.
- Respect safe areas.
- Ensure the FAB does not cover the final list item; provide sufficient scroll padding.
- Horizontal swipe must use an intentional threshold/velocity rule and settle correctly when interrupted.
- Only one row should remain meaningfully displaced/open at a time if an open-state design is used.
- Never let horizontal gesture handling make vertical list scrolling feel broken.
- Use animation controllers defensively; interrupted/reversed animations must settle to valid states.

## Verification

At the end of every implementation prompt:
1. run `dart format` on changed Dart files;
2. run `flutter analyze`;
3. run `flutter test`;
4. inspect `git diff`;
5. make only scope-related fixes;
6. commit only when the prompt explicitly asks for a commit.

Do not proceed into the next prompt's feature set.

If a requested visual value cannot be established from the supplied sources, say so in the task summary instead of pretending it is exact.
