# Design Reference

This file separates **verified/extracted facts** from **interpretation**. Do not convert an interpretation into an "exact Figma value."

## Frame inventory

The supplied overview contains:

1. `01 — Home Empty`
2. `02 — Home Notes ...`
3. `03 — Swipe to Del...`
4. `04 — Swipe to Favo...`
5. `05 — Favorites List`
6. `06 — Filter View`
7. `07 — Search`
8. `08 — Search No R...`
9. `09 — New Note E...`
10. `10 — Editor with C...`
11. `11 — Editor Favorite`
12. `12 — Save Dialog`
13. `13 — Discard Dialog`
14. `14 — Reading Note`

We implement frame 06 and do not separately implement frame 05.

## Verified rendered colors

These values were extracted from the supplied native Figma archive's rendered data/reference images.

| Purpose | Hex |
|---|---|
| App background | `#252525` |
| Note magenta | `#FD99FF` |
| Note pink | `#FF9E9E` |
| Note green | `#91F48F` |
| Note yellow | `#FFF599` |
| Note cyan | `#9EFFFF` |
| Note purple | `#B69CFF` |
| Delete swipe | `#FF0000` |
| Favorite swipe | `#FFD700` |
| Common dark surface | `#454545` |
| Common smaller control surface | `#3B3B3B` |

The rendered files also contain white and multiple grey text/control shades. Their exact semantic mapping has not been decoded from the Figma node tree, so inspect `overview.png` instead of inventing names/roles.

## Exact extracted raster assets

Use the highest useful resolution and let Flutter scale it down:

- `.codex_reference/assets/empty_notes_2000.png`
- `.codex_reference/assets/empty_notes_500.png`
- `.codex_reference/assets/search_no_results_2000.png`
- `.codex_reference/assets/search_no_results_500.png`

The 2000×2000 versions are preferred source assets.

Two embedded JPEGs (`device_reference_423x858.jpg` and `device_reference_212x429.jpg`) are source/device references, not runtime app assets.

## Native `.fig`

`.codex_reference/design.fig` is the original uploaded local Figma file.

The archive contains a binary `canvas.fig`, metadata, a thumbnail and image blobs. The icons are not standalone image files; they are represented inside the canvas/vector data.

Do not assume Codex can fully decode native Figma vector/node data. If a compatible parser is actually available, extraction is welcome. Otherwise use the rendered references.

## Icons visible in the design

Visible controls include:
- search
- info
- add/plus
- trash
- star outline
- star/favorite active state
- back chevron
- eye/preview
- save/floppy
- edit/pencil
- close/X
- static formatting-toolbar glyphs

No separate icon assets were found in the image payload of the `.fig`.

Do not install an icon/UI package. Use a Flutter built-in icon only if it visually matches well; otherwise draw the small icon locally with `CustomPainter`/path data.

## Things that are NOT app UI

- The labels above each phone frame are Figma frame names.
- The bright blue outline around frame 14 is the Figma selection highlight.
- The software keyboard visible in search/editor frames is the operating system keyboard.
- The grey canvas outside phone frames is the Figma canvas/background.

## Note sample colors shown

The design associates these sample notes with:

| Note | Color |
|---|---|
| UI concepts worth existing | magenta |
| Book Review: The Design of Everyday Things by Don Norman | pink |
| Animes produced by Ufotable | green |
| Mangas planned to read | yellow |
| Awesome tweets collection | cyan |
| List of free & open source apps | purple |

The design contains no color picker and does not specify a creation rule. Our chosen implementation auto-cycles the palette and persists the assigned color.

## Visual implementation guidance

The challenge explicitly prioritizes structure, spacing rhythm and correct states over pixel-perfect redlines. Still:
- inspect the overview at high zoom;
- use consistent page insets and vertical rhythm;
- keep cards flexible instead of fixing heights;
- preserve rounded cards/controls and the compact dark visual language;
- ensure content can scroll clear of the FAB;
- do not recreate the old device width as a fixed-width centered column on wide screens.

## Typography

The exact Figma font metadata has **not** been decoded from `canvas.fig`. Do not claim a font family/weight/size is exact based on this pack alone. Match visually using the rendered references and keep text responsive.
