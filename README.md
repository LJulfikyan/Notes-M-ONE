# Notes M-ONE

Flutter implementation of the M-One Notes challenge.

> **Applying level:** TODO — fill this before submission.

## Run

```bash
flutter pub get
flutter run
```

## State management

MobX is used because the app has a small reactive state graph with clear derived views such as filters and search results. Persistence remains behind a repository boundary so UI state and storage concerns stay separate.

## Persistence

Notes and editor drafts are stored locally in SQLite.

## Design choice: frame 06

The implementation uses **06 — Filter View** rather than 05 — Favorites List. A filter model scales more cleanly and keeps `All`, `Favorites`, and `Recent` as explicit list modes.

`Recent` is interpreted as all notes ordered by `updatedAt` descending because the design does not define a time window.

## Responsive checks

TODO after implementation: record the actual devices/emulators, viewport sizes and text scales checked.

Target checks:
- narrow phone width
- typical phone width
- wider/tablet-like width
- text scale 1.0
- increased text scale
- long titles and long bodies

## What is still wrong with this

Required submission section. Do not remove it.

TODO near submission: list real known issues in the implemented code. Do not invent issues and do not claim perfection.

## Design notes

The source design intentionally contains gaps and contradictions. Current identified items are maintained in `docs/DESIGN_NOTES_DRAFT.md` and should be summarized here before submission.

Key examples:
- plain-text requirement conflicts with rich-text-looking styling/toolbar;
- favorite icon treatment is inconsistent;
- editor eye/star control changes meaning;
- search exit/empty-query semantics are unspecified;
- `"File not found"` is inconsistent terminology for a Notes app;
- save/discard dialog triggers are underspecified;
- note colors have no assignment/selection interaction;
- fixed Figma placement lets the FAB overlap content unless the real list adds bottom padding.

## AI context

See `AI/context.md`.
