# Notes M-ONE

Flutter implementation of the M-One Notes challenge: a local-first notes app
with custom swipe actions, durable editor drafts, filters, search, reading, and
the supplied empty states.

TODO: Applying level

## How to run

Use a current stable Flutter SDK with an iOS or Android target available.

```bash
flutter pub get
flutter run
```

Verification commands:

```bash
flutter analyze
flutter test
```

## Architecture

The dependency direction is deliberately small:

```text
Flutter UI -> MobX NotesStore -> NotesRepository -> SQLite
```

MobX was chosen because the app has a small observable state surface and a few
derived views, notably filters and search results. SQLite remains isolated
behind `NotesRepository`, so presentation code does not know about SQL.
Built-in `Navigator` handles the small route set without a routing or
dependency-injection framework.

## Persistence and drafts

SQLite stores each note's plain-string title/body, persisted color, favorite
flag, and timestamps. New notes cycle through the supplied six-color palette;
the assigned color is stored rather than inferred from list position.

The editor persists durable drafts separately from saved notes. Draft writes
are debounced, serialized, and flushed at lifecycle/disposal boundaries to
protect unsaved input across process termination. Save commits the current
draft to the note, updates `updatedAt`, and clears the draft. Discard clears the
draft without changing the previously saved note.

## Implemented frames and frame 06 choice

The app covers frames 01–04 and 06–14. Frame 05 is intentionally omitted
because the brief defines frames 05 and 06 as alternatives; this project chose
**06 — Filter View**. `All`, `Favorites`, and `Recent` provide a clearer,
scalable list model than a separate favorites screen.

The Figma does not specify how frame 06 is entered. Its filters are therefore
treated as part of populated Home instead of overloading the unrelated Info
control. Info remains visible, but no destination is invented for it.

`Recent` means all notes ordered by `updatedAt` descending. This is an explicit
implementation assumption because the design does not define a recent time
window.

The covered states include empty/populated Home, custom delete/favorite swipe
reveals, filters, blank/no-result Search, new/content/favorite Editor states,
Save/Discard dialogs, and the read-only Reader.

## Responsive verification

Manual verification performed:

- Approximately 393×852 logical pixels on the iPhone simulator at the default
  text setting, including the final visual and Nunito typography checks.

Widget-test coverage:

- Home empty/populated states at 320×720, 393×720, and 768×720 logical pixels.
- Home text scales 0.9, 1.0, and 1.5, with long titles and bodies.
- Reference geometry at 393×852 for Home, filters, swipe states, Search,
  Editor, dialogs, and Reader.
- Narrow Search at 280×640 and narrow Editor/dialog coverage at 320×720.
- Increased text-scale checks for Search, Editor, dialogs, Reader, and long
  wrapping/scrollable content.

The final 68-test suite also covers filter/search derivation, note CRUD and
color persistence, durable draft recovery and lifecycle flushing,
Save/Discard/Keep outcomes, reader refresh after editing, and custom swipe
thresholds, cancellation, interruption, dynamic card/background sizing,
single-open-row behavior, and tap-only actions.

## What is still wrong with this

- Some icon shapes use visually matched built-in Flutter glyphs because the
  native Figma vector paths were not extracted.
- The Info control remains inert because the design specifies no destination;
  frame-06 filters are directly visible on populated Home.
- The italic-looking Reader sample cannot be represented because the challenge
  requires plain-string note content.
- `Recent` is an inferred `updatedAt`-descending interpretation because the
  design defines neither a time window nor ordering semantics.
- Secondary typography not explicitly inspected in Figma was visually matched.
- Draft writes are debounced; text entered immediately before an abrupt process
  termination could be lost if Flutter receives no lifecycle callback and the
  pending SQLite write has not run.

## Design notes

- Notes remain plain `title` and `body` strings, so the italic-looking sample
  content is intentionally not reproduced.
- The rich-text-looking toolbar is rendered as a decorative 11-control row;
  there is no formatting, rich-text, or markdown model.
- Favorite glyph treatment varies across the Figma. The app uses outline stars
  for cards and swipe context, plus the yellow outline editor state, without
  adding another favorite interaction.
- Frames 09/10 show an eye where frame 11 shows a star. The editor preserves
  that state-dependent shared control slot.
- Search exit semantics are unspecified. The implementation makes X clear the
  query and system Back exit Search; an empty query shows frame 07's blank
  state.
- `"File not found. Try searching again."` is preserved for fidelity despite
  its file-browser terminology.
- Dirty Save opens Save/Discard; dirty Back opens Discard/Keep; clean Back exits
  immediately. These triggers were inferred because the frames do not define
  them.
- Separate draft persistence reconciles explicit Save with process-kill
  resilience.
- The fixed Figma lets the FAB overlap lower content; the implementation adds
  bottom scroll clearance so the final note remains reachable.
- The design has six note colors but no picker or assignment rule, so new notes
  cycle through the palette and persist their assigned color.
- `Recent` was undefined and is explicitly interpreted as `updatedAt`
  descending.
- Frame 14's blue border, frame labels, gray canvas, and shown keyboard are
  Figma/system chrome rather than application UI.
- Frame 06 has no specified entry behavior, so filters are directly visible on
  populated Home instead of overloading the Info control.

## AI context

See [AI/context.md](AI/context.md) for architecture constraints, design traps,
reference priorities, and guidance for future coding agents.

## Submission checklist

- Fill in the applying level above.
- Record the required unedited approximately three-minute coding video with
  spoken explanation.
- Push this repository publicly and submit its link with the recording.
