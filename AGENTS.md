# AGENTS.md

## Project

This repository is the M-One Flutter Notes challenge.

Build a small, production-quality local notes app that closely follows the supplied design while making deliberate decisions where the design is incomplete or contradictory.

For every UI task:

* read `docs/VISUAL_ACCEPTANCE.md`;
* read `docs/REFERENCE_GEOMETRY.md`;
* treat the supplied Figma/reference material as the visual source of truth;
* do not substitute default Material widget dimensions or behavior when they conflict with the design.

At the approximately `393×852` reference viewport, the measured geometry in `docs/REFERENCE_GEOMETRY.md` is the visual calibration baseline. Preserve responsive behavior at other widths and text scales.

Before changing code, read:

* `AI/context.md`
* `docs/CHALLENGE_SUMMARY.md`
* `docs/DESIGN_REFERENCE.md`
* `docs/DESIGN_NOTES_DRAFT.md`
* `docs/ARCHITECTURE.md`

Local design references are under `.codex_reference/`.

---

## Non-negotiable challenge rules

* Implement frames 01–14, except implement **06 Filter View** and do not separately implement 05 Favorites List.
* Notes contain plain-string `title` and `body`.
* No rich-text, markdown, or formatting data model.
* The editor formatting toolbar is static/decorative only.
* Persist notes and drafts locally.
* No backend, sync, auth, tags, folders, or design-system project.
* Do not use third-party packages to provide visual UI components.
* Do not use Flutter `Dismissible`.
* Custom horizontal swipe behavior must coexist cleanly with vertical scrolling.
* The app must be responsive and tolerate larger text scales and long content.
* Do not silently hide known design contradictions. Resolve them deliberately and document the decision.
* Do not broaden product scope unless a task explicitly requires it.

---

## Architecture

Use a deliberately small architecture:

`Flutter UI -> MobX NotesStore -> NotesRepository -> SQLite`

Allowed non-visual dependencies:

* `mobx`
* `flutter_mobx`
* `mobx_codegen`
* `build_runner`
* `sqflite`
* `path`

Do not introduce:

* Riverpod
* Bloc
* Provider
* GetX
* GoRouter
* a DI package
* Freezed
* generic clean-architecture frameworks
* use-case/interactor layers
* a design-system package

unless a task explicitly changes this decision.

Use built-in `Navigator` unless a concrete requirement makes that insufficient.

UI must not access SQLite directly.

Do not store `BuildContext` or Navigator state inside MobX stores.

---

## File organization

Use **one primary implementation concept per file**.

Examples:

* `Note` -> `note.dart`
* `NoteDraft` -> `note_draft.dart`
* `NotesStore` -> `notes_store.dart`
* `NotesRepository` -> `notes_repository.dart`
* `SqliteNotesRepository` -> `sqlite_notes_repository.dart`
* `HomePage` -> `home_page.dart`
* `NoteCard` -> `note_card.dart`

### Important Flutter exception

A `StatefulWidget` and its private `State` class belong in the **same Dart file**.

Correct:

```dart
class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  // ...
}
```

Do **not** move `_NoteEditorPageState` into a separate file merely to satisfy a literal one-class-per-file rule.

The same-file exception also applies to small private implementation details that:

* exist only for the owning widget;
* are not reusable elsewhere;
* are clearer when colocated with that widget.

Independent reusable widgets, stores, repositories, models, services, and other meaningful concepts should still have their own files.

Generated companion code such as MobX-generated files follows the generator's normal structure.

Do not split code mechanically if doing so makes the code harder to understand.

---

## Domain rules

A saved note contains, at minimum:

* id
* title
* body
* persisted note color
* favorite flag
* createdAt
* updatedAt

The verified note palette is:

* magenta `#FD99FF`
* pink `#FF9E9E`
* green `#91F48F`
* yellow `#FFF599`
* cyan `#9EFFFF`
* purple `#B69CFF`

New notes receive colors automatically by cycling through this palette.

The assigned color is persisted with the note.

Never derive an existing note's color from its current list index.

Default list ordering:

* newest created first.

`Recent` means:

* all notes ordered by `updatedAt` descending.

This is an explicit design assumption and must remain documented.

---

## Draft/process-kill rule

Saved-note semantics and draft semantics are separate.

While editing:

* persist a draft locally without overwriting the saved note;
* saving promotes the draft into the saved note and clears the draft;
* discarding clears the draft;
* a process kill must not erase typed text.

Keep this implementation small.

Do not add:

* background sync;
* complex event sourcing;
* complex undo architecture;
* hidden auto-save semantics that replace explicit Save.

---

## Typography

The application uses locally bundled **Nunito**.

Do not rely on platform-default fonts.

Verified Figma typography includes:

### Home heading

* family: Nunito
* weight: 600
* size: 43
* line-height: 100%
* letter-spacing: 0

### Note/card text

* family: Nunito
* weight: 400
* size: 25
* line-height: 100%
* letter-spacing: 0

### Editor title

* family: Nunito
* weight: 400
* size: 48
* line-height: 100%
* letter-spacing: 0

### Editor body

* family: Nunito
* weight: 400
* size: 23
* line-height: 100%
* letter-spacing: 0

### Empty-state caption

* family: Nunito
* weight: 300
* size: 20
* line-height: 100%
* letter-spacing: 0

### Filters

Selected:

* family: Nunito
* weight: 700
* size: 16
* line-height: 100%
* letter-spacing: 0

Unselected:

* family: Nunito
* weight: 600
* size: 16
* line-height: 100%
* letter-spacing: 0

Required bundled weights include:

* 300
* 400
* 600
* 700

Unknown secondary text styles may use Nunito while preserving their currently verified local size/weight unless exact Figma values have been established.

Do not guess exact typography values.

### Icon-font warning

Nunito applies to normal text, not graphical Flutter `IconData`.

Do not render Material icon code points as Nunito text.

Graphical icons must use:

* `Icon`
* `CustomPainter`
* local path/vector drawing

as appropriate.

Do not convert `IconData.codePoint` into a `Text` glyph using Nunito.

Literal formatting letters such as `B`, `I`, and `U` may remain text.

---

## Figma/reference rules

Reference priority:

1. `.codex_reference/overview.png`
2. extracted illustration assets
3. `.codex_reference/figma_thumbnail.png`
4. `docs/DESIGN_REFERENCE.md`
5. native `.codex_reference/design.fig` only when an actual parser is available

Do not invent "exact Figma values" that have not been extracted or measured.

The bright blue border around frame 14 is a Figma selection indicator, not app UI.

The labels above frames are Figma frame names, not app UI.

The shown software keyboard is the system keyboard; never recreate it in Flutter.

Icons are not separate raster assets in the `.fig` archive.

Do not assume a Material icon is exact merely because it is similar.

Prefer built-in icons only when visually close enough. Otherwise use a small local `CustomPainter` or path implementation.

Do not add an icon/UI package.

---

## Interaction decisions

### Home / Reader

* Home card tap -> Reading Note.
* Search result tap -> Reading Note.
* FAB -> New Note editor.
* Reader Edit -> Editor for that note.

A closed note card must remain tappable even when wrapped by the custom swipe implementation.

### Swipe favorite

Swipe right:

* reveals a yellow action area on the left;
* foreground retains full width and translates right;
* no yellow is visible at rest;
* action does not fire merely because the drag passes a threshold;
* tapping the revealed favorite action toggles favorite;
* row closes afterward.

### Swipe delete

Swipe left:

* moves the note foreground away;
* full note row becomes red;
* trash icon is centered in the complete row;
* swipe alone does not delete;
* tapping the revealed delete action deletes.

Do not use `Dismissible`.

### Open swipe row

If an action is revealed:

* tapping the action performs the action;
* tapping the displaced note foreground closes the row first;
* that same tap should not also navigate to Reader.

Only one row should remain meaningfully open at a time.

### Search

* Search X -> clear query.
* System/back navigation exits Search.
* Empty query -> blank state matching frame 07.
* Preserve exact no-results copy:
  `"File not found. Try searching again."`

Do not replace it with corrected terminology unless the task explicitly changes the design decision.

### Info

* Info opens the compact instructional notes popup.
* It must not toggle filters or navigate to another page.
* The popup closes with `Got it` or normal platform Back.

### Editor / Preview

Editor View/Preview must **not** push another Reader route repeatedly.

Edit and Preview are two presentation modes of the same editor route.

Required behavior:

* Edit -> View switches to preview mode in the same route;
* preview displays the current draft, including unsaved changes;
* Preview -> Edit returns to editing in the same route;
* repeatedly switching Edit/View must not grow the Navigator stack;
* Back from Preview returns to Edit mode;
* Back from dirty Edit -> frame 13 discard confirmation;
* Back from clean Edit -> pop immediately.

Reader -> Edit may remain normal Navigator navigation.

### Save

Save icon from dirty Editor -> frame 12 Save confirmation.

Save:

* commits draft;
* updates saved note;
* clears draft.

### Discard

Dirty Editor Back -> frame 13 discard confirmation.

Discard:

* clears draft;
* preserves previously saved note.

Keep:

* closes dialog;
* remains in editor;
* preserves draft.

### Editor controls

* Nonfavorite editor shows Eye/View control as in frames 09/10.
* Favorite editor shows yellow outline Star state as in frame 11.
* Do not invent extra controls merely to reconcile the design inconsistency.

---

## UI quality

* Keep card text wrapping naturally.
* Note cards use `EdgeInsets.all(28)` and content-driven height; do not restore
  a fixed or arbitrary minimum card height.
* Shared header/action controls are 50×50 with radius 15 and 24×24 icons.
* Do not reduce verified Figma font sizes merely to avoid wrapping.
* Avoid hard-coded screen heights.
* Respect safe areas.
* Ensure the FAB does not cover the final list item; provide sufficient scroll padding.
* Avoid default Material component dimensions when they visibly conflict with Figma.
* Avoid uncontrolled circular splash effects outside visible rounded controls.
* Press feedback must remain visually contained.
* Horizontal swipe must use intentional threshold/velocity behavior.
* Horizontal gestures must not make vertical scrolling feel broken.
* Interrupted/reversed animations must settle into valid states.
* Do not globally scale the UI as a bitmap to match one viewport.
* At the reference viewport, match Figma closely; at other sizes, preserve responsive usability.

---

## Material-default rule

Default Material behavior is not automatically the design specification.

Audit carefully before relying on:

* `IconButton`
* `FloatingActionButton`
* `AlertDialog`
* `TextButton`
* `FilledButton`
* `ChoiceChip`
* `SearchBar`
* `ListTile`

These widgets may still be used if explicitly styled to match the design.

Do not replace working widgets purely for stylistic purity.

---

## Editor formatting toolbar

The formatting toolbar is static/decorative.

It must not:

* apply bold;
* apply italic;
* apply underline;
* create lists;
* change alignment;
* create links;
* introduce rich-text state.

When shown, it belongs with the active keyboard/editing state and should not remain stranded at the bottom when the keyboard is dismissed.

---

## Known design contradictions

Do not silently "fix" these without documenting the decision:

* plain-string requirement vs italic-looking body text in Figma;
* decorative formatting toolbar vs no rich-text support;
* favorite-star presentation inconsistency;
* Eye vs Star control inconsistency in editor states;
* Search X/exit behavior is unspecified;
* `"File not found"` terminology is inconsistent with a Notes app;
* Save/Discard trigger semantics are not fully defined by the frames;
* explicit Save vs process-kill resilience requires separate draft persistence;
* note colors exist but no color-selection interaction is specified;
* Recent has no supplied definition;
* frame 06 has no supplied entry behavior and must not be attached to Info;
* frame 14 blue border is Figma selection chrome.

---

## Scope discipline

For every task:

* inspect existing code before replacing it;
* preserve already accepted behavior unless the task explicitly changes it;
* do not perform opportunistic refactors;
* do not redesign unrelated screens;
* do not add packages without a concrete need;
* do not broaden scope to "clean up the whole app";
* make the smallest correct change that satisfies the requested behavior.

If fixing a regression, identify the cause before restructuring surrounding code.

---

## Verification

At the end of every implementation task:

1. run `dart format` on changed Dart files, or `dart format .` where appropriate;
2. run `flutter analyze`;
3. run `flutter test`;
4. run `git diff --check`;
5. inspect `git status`;
6. inspect the relevant `git diff`;
7. make only scope-related fixes;
8. commit only when the prompt explicitly asks for a commit.

Do not proceed into the next task automatically.

If a requested visual value cannot be established from the supplied sources, say so in the task summary instead of pretending it is exact.

If the working tree contains unrelated pre-existing changes, do not stage them unless the prompt explicitly asks you to do so.
