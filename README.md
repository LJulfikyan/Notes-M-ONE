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

MobX was chosen for the app's small reactive state graph and derived views such
as filters and search results. SQLite remains isolated behind
`NotesRepository`, so presentation code does not know about SQL. Built-in
`Navigator` handles the small route set without a routing or dependency-
injection framework.

## Persistence and drafts

SQLite stores each note's plain-string title/body, persisted color, favorite
flag, and timestamps. New notes cycle through the supplied six-color palette;
the assigned color is stored rather than inferred from list position.

The editor persists drafts separately from saved notes. Draft writes are
debounced, serialized, and flushed at lifecycle/disposal boundaries to protect
unsaved input from process termination. Save commits the draft to the note,
updates `updatedAt`, and clears the draft. Discard clears the draft without
changing the previously saved note.

## Implemented frames and frame 06 choice

The app covers frames 01–04 and 06–14. Frame 05 is intentionally omitted
because the brief defines frames 05 and 06 as alternatives; this project chose
**06 — Filter View**. `All`, `Favorites`, and `Recent` provide a clearer,
scalable list model than a separate favorites screen.

`Recent` means all notes ordered by `updatedAt` descending. This is an explicit
implementation assumption because the design does not define a recent time
window.

The covered states include empty/populated Home, custom delete/favorite swipe
reveals, filters, blank/no-result Search, new/content/favorite Editor states,
Save/Discard dialogs, and the read-only Reader.

## Responsive verification

Manual verification:

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

The 52-test suite also covers filter/search derivation, note CRUD and color
persistence, durable draft recovery and lifecycle flushing, Save/Discard/Keep
outcomes, reader refresh after editing, and custom swipe thresholds,
cancellation, interruption, single-open-row behavior, and tap-only actions.

## What is still wrong with this

- Exact native Figma vector paths were not available for the icons, so the app
  uses visually close built-in Flutter glyphs.
- Nunito and the directly verified Home/card/Editor/empty-caption styles are
  exact, but secondary text sizes and weights were visually matched because
  those Figma layer values were not extracted.
- The header's info-shaped control exposes frame 06 filters. The design does
  not define a separate Info destination, so none was invented.
- The Figma italicizes a sample Reader paragraph, but the challenge requires
  plain strings; the app intentionally renders it as plain text.
- Draft persistence is deliberately small and robust, but input entered within
  the debounce window could still be lost if the operating system terminates
  the process before Flutter receives a lifecycle callback or SQLite write.
- `Recent` is an explicit `updatedAt`-descending interpretation because the
  design gives no time-window semantics.

## Design notes

- Notes remain plain `title` and `body` strings. No rich-text, markdown, or
  formatting model was added; the formatting toolbar is decorative.
- Favorite glyphs vary across the Figma. The app keeps outline stars for swipe
  and list contexts and a yellow outlined editor state rather than inventing
  additional favorite controls.
- Frames 09/10 show an eye where frame 11 shows a star. The editor preserves
  that state-dependent shared control slot.
- Search X clears the query; system Back exits Search. An empty query shows the
  blank frame-07 state.
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
- `Recent` is defined as `updatedAt` descending.
- Frame 14's blue border, frame labels, gray canvas, and shown keyboard are
  Figma/system chrome rather than application UI.

## AI context

See [AI/context.md](AI/context.md) for architecture constraints, design traps,
reference priorities, and guidance for future coding agents.

## Submission checklist

- Fill in the applying level above.
- Record the required unedited approximately three-minute coding video with
  spoken explanation.
- Push this repository publicly and submit its link with the recording.
