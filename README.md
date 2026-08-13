# Notes M-ONE

Flutter implementation of the M-One Notes challenge: a local-first notes app with custom swipe interactions, durable editor drafts, filtering, search, editing, previewing, and read-only note presentation.

**Applying level:** TODO

## Running the project

Use a current stable Flutter SDK with an iOS or Android target available.

```bash
flutter pub get
flutter run
```

Verification:

```bash
flutter analyze
flutter test
```

## Architecture

The application deliberately uses a small dependency direction:

```text
Flutter UI -> MobX NotesStore -> NotesRepository -> SQLite
```

MobX was chosen because the application has a small observable state surface with several derived views, especially filtering and search.

SQLite remains isolated behind `NotesRepository`, so presentation code does not know about SQL or storage implementation details.

Flutter's built-in `Navigator` is sufficient for the small route set and avoids introducing an additional routing or dependency-injection framework.

The project follows a **one primary implementation concept per file** convention. A `StatefulWidget` and its private `State` class remain colocated because they form one Flutter implementation unit.

## Local persistence and drafts

Each note persists:

* plain-string title
* plain-string body
* note color
* favorite state
* creation timestamp
* update timestamp

The design contains six note colors:

* `#FD99FF`
* `#FF9E9E`
* `#91F48F`
* `#FFF599`
* `#9EFFFF`
* `#B69CFF`

The Figma does not define how a color is selected when creating a note. New notes therefore cycle through the supplied palette, and the assigned color is persisted with the note rather than derived from its current list position.

Editor drafts are stored separately from saved notes.

Draft writes are debounced and flushed at relevant lifecycle/disposal boundaries so unsaved input can survive process termination without silently overwriting the saved note.

Saving:

* commits the current draft;
* updates `updatedAt`;
* clears the draft.

Discarding:

* clears the draft;
* leaves the previously saved note unchanged.

## Implemented design states

The implementation covers:

* 01 — Home Empty
* 02 — Home Notes
* 03 — Swipe Delete
* 04 — Swipe Favorite
* 06 — Filter View
* 07 — Search
* 08 — Search No Results
* 09 — New Note Editor
* 10 — Editor with Content
* 11 — Editor Favorite
* 12 — Save Dialog
* 13 — Discard Dialog
* 14 — Reading Note

Frame 05 is intentionally omitted because the assignment defines frames 05 and 06 as alternative answers to the same requirement.

This implementation uses **06 — Filter View**.

## Filter behavior

The populated Home view exposes:

* `All`
* `Favorites`
* `Recent`

`Recent` is interpreted as all notes ordered by `updatedAt` descending.

This is an explicit implementation assumption because the supplied design does not define a time window or ordering semantics for "Recent."

The exact verified filter typography is:

* selected: Nunito 700, 16px
* unselected: Nunito 600, 16px
* 100% line height
* 0 letter spacing

## Info control assumption

The supplied design shows an Info control but does not define a destination or interaction for it.

Rather than assigning unrelated navigation to the button or using it to reveal filters, the implementation opens a small informational popup explaining the available interactions:

* notes are stored locally;
* swipe right reveals Favorite;
* swipe left reveals Delete;
* `All`, `Favorites`, and `Recent` filter the note list.

This behavior is an explicit implementation assumption.

## Swipe interactions

The application does not use Flutter `Dismissible`.

Both interactions are implemented with custom horizontal gesture and animation handling so they can coexist with vertical list scrolling.

### Favorite

Swiping right reveals the yellow Favorite action on the left.

The note foreground remains full width and is translated rather than resized.

When fully revealed:

* the yellow action remains on the left;
* the star is centered inside the revealed action;
* the note's left corners become square at the seam;
* the right corners remain rounded.

Favorite is triggered by tapping the revealed action rather than automatically crossing a swipe threshold.

### Delete

Swiping left moves the complete note foreground away and reveals the full-width red delete state.

The trash icon is centered in the complete row.

Crossing the swipe threshold does not immediately delete the note. Deletion requires a deliberate tap on the revealed delete state.

Only one row can remain meaningfully open at a time.

## Note cards

Note cards are content-driven rather than fixed-height.

Internal padding is:

```text
28px on all four sides
```

Card text uses the verified Figma typography:

* Nunito
* weight 400
* size 25px
* 100% line height
* 0 letter spacing

A short note is therefore naturally shorter than a wrapped multi-line note.

Favorite notes display the outline-star state shown in the design.

## Typography

The application bundles Nunito locally rather than relying on platform-default fonts.

Verified Figma styles include:

### Home heading

* Nunito
* 600
* 43px
* 100% line height
* 0 letter spacing

### Note text

* Nunito
* 400
* 25px
* 100% line height
* 0 letter spacing

### Editor title

* Nunito
* 400
* 48px
* 100% line height
* 0 letter spacing

### Editor body

* Nunito
* 400
* 23px
* 100% line height
* 0 letter spacing

### Empty-state caption

* Nunito
* 300
* 20px
* 100% line height
* 0 letter spacing

The required Nunito weights are bundled with the application, together with the font license.

Graphical Flutter icons do not inherit Nunito and use their proper icon/vector rendering.

## Header controls

Verified Figma geometry for the shared header controls is:

```text
50 × 50
border radius: 15
inner icon: 24 × 24
```

This geometry is shared across controls such as:

* Search
* Info
* Back
* Eye
* Save
* Favorite
* Edit

Interaction feedback is contained inside the visible rounded control instead of allowing default Material splash effects to escape its bounds.

## Editor and preview

Editor and Preview are two presentation modes of the **same route**.

Switching repeatedly between:

```text
Edit -> View -> Edit -> View
```

does not push additional pages onto the Navigator stack.

Preview displays the current draft, including unsaved changes.

Back from Preview returns to Edit mode.

From Edit:

* dirty Back opens the Discard dialog;
* clean Back exits normally;
* dirty Save opens the Save confirmation.

This avoids an indefinitely growing navigation stack while still allowing unsaved content to be previewed.

## Formatting toolbar

The toolbar shown above the keyboard is reproduced as a static 11-control row:

1. Bold
2. Italic
3. Underline
4. Link
5. Strikethrough
6. Numbered list
7. Bulleted list
8. Code
9. Text
10. Sigma
11. Checklist

It is deliberately non-functional.

The written challenge explicitly requires note content to remain plain text, so the toolbar does not introduce rich-text, markdown, spans, or formatting state.

## Search

Search matches both title and body case-insensitively.

An empty query reproduces the blank Search state from the design.

The X control clears the query rather than leaving Search.

System Back exits the Search screen.

The no-results copy is preserved exactly from the supplied design:

> File not found. Try searching again.

Although the wording is unusual for a Notes application, it is kept for visual/content fidelity.

## Responsive verification

### Manual verification

The application was manually checked at approximately:

```text
393 × 852 logical pixels
```

on an iPhone simulator at the default text setting.

This included final visual verification after applying the exact Nunito typography and measured Figma geometry.

### Widget-test coverage

The test suite includes responsive and behavioral coverage for:

* Home empty/populated states at multiple widths
* narrow phone layouts
* wider layouts
* increased text scales
* long titles
* long bodies
* dynamic note-card heights
* Home/filter reference geometry
* Search states
* Editor states
* Preview/Edit switching
* dialogs
* Reader
* swipe thresholds
* swipe cancellation/interruption
* favorite/delete tap-only actions
* single-open-row behavior
* draft recovery
* lifecycle draft flushing
* Save / Discard / Keep outcomes
* Reader refresh after editing
* note CRUD
* color persistence
* filter derivation
* search derivation

The final verification commands are:

```bash
flutter analyze
flutter test
```

## Design assumptions and contradictions

The supplied design intentionally contains gaps and contradictions. These were treated as implementation decisions rather than silently hidden.

### Plain text vs visually formatted sample

The challenge explicitly requires title and body to remain plain strings, while one supplied sample visually contains italic text.

The implementation keeps the body plain and does not special-case sample content.

### Formatting toolbar vs plain-text model

The toolbar visually suggests rich-text editing, but the challenge explicitly excludes formatting.

It is therefore rendered as a decorative/static toolbar only.

### Favorite-state presentation

Favorite stars are not presented completely consistently across the supplied frames.

The implementation preserves the main visual states without introducing additional undocumented favorite interactions.

### Eye vs Star in the Editor

Frames 09/10 show an Eye control where frame 11 shows a Star.

The implementation preserves this state-dependent shared control position rather than inventing another toolbar action.

### Save and Discard triggers

The individual frames show Save and Discard dialogs without fully defining what causes each one.

The implementation interprets them as:

* dirty Save -> Save / Discard dialog
* dirty Back -> Discard / Keep dialog
* clean Back -> exit directly

### Explicit Save vs process termination

Explicit Save implies that unsaved edits should not immediately overwrite the persisted note.

The requirement that input survive process termination is therefore handled through separate draft persistence.

### Note colors

Six note colors are supplied, but there is no color picker or assignment rule.

The implementation cycles through the supplied palette and persists the result.

### Recent

The design does not define what "Recent" means.

The implementation uses `updatedAt` descending.

### Info control

The design shows an Info button without defining its behavior.

The implementation uses it for a small instructional popup rather than inventing a new screen or using it as a filter toggle.

### Frame 14 selection border

The blue border shown around frame 14 is Figma selection chrome and is not rendered by the application.

Likewise, Figma frame labels, the gray canvas, and the software keyboard shown in the design reference are not application UI.

## What is still wrong with this

The implementation is intentionally not presented as pixel-perfect Dev Mode reconstruction.

Known limitations include:

* some icon shapes use visually matched Flutter/custom glyphs because exact native Figma vector paths were not extracted;
* typography values explicitly inspected in Figma are exact, while some secondary text styles were visually matched;
* the visually italic sample body cannot be represented without violating the plain-string content requirement;
* `Recent` semantics had to be inferred;
* Info behavior had to be inferred;
* draft writes are debounced, so an extremely abrupt process termination before a pending SQLite write or lifecycle flush completes may still lose the most recent characters.

These tradeoffs are intentionally documented rather than hidden.

## AI context

`AI/context.md` contains the working context used for AI-assisted development of the project.

It documents:

* architecture
* persistence boundaries
* MobX conventions
* draft behavior
* Figma reference priorities
* visual constraints
* custom swipe rules
* typography
* file-organization conventions
* known design traps
* prohibited implementation choices
* verification commands

The file is intended to provide enough project-specific context for another coding agent to make a small, correct change without relying on generic Flutter conventions.

## Tests

Run the full suite with:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

Tests are focused on actual behavior and responsive states rather than token pump-only coverage.

## Screen recording

An unedited [screen recording is available on Google Drive](https://drive.google.com/file/d/127_RcdLeqT0KXbXHu3hUPWuqiX1jz50P/view?usp=sharing). It is hosted externally because the recording is too large to include in the repository.

The recording demonstrates:

* visual comparison of the running application against the supplied Figma;
* execution of the project test command;
* Codex running against the repository;
* the implementation prompt being used during the recording;
* a mistake identified during the final part of the recording.

The recording was captured without microphone audio, so no spoken commentary is present. The visible workflow, prompt, test execution, application state, and issue discovered at the end are intended to provide the development context that would otherwise have been described verbally.
