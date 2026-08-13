# Visual & Interaction Acceptance

This document overrides generic Flutter/Material conventions when they conflict
with the supplied Figma.

The goal is to reproduce the Figma, not to make the UI look like a default
Material application.

## Reference priority

For visual work inspect:

1. `.codex_reference/overview.png`
2. `.codex_reference/figma_thumbnail.png`
3. exact extracted illustration assets
4. `docs/DESIGN_REFERENCE.md`

Do not infer visual behavior from standard Flutter widgets when the Figma shows
something different.

---

# Global rules

## Layout

- A note row always occupies the available list width.
- Card width must never depend on title/body length.
- Short text must not cause the card foreground to shrink.
- Swipe action backgrounds must be completely hidden when offset is zero.
- Nothing underneath a note may be visible in its resting state.
- Do not hard-code the old Figma phone screen as the only supported width.
- At the reference phone width, proportions and spacing should visually match
  the Figma before applying responsive behavior to other widths.

## Colors

Use the verified palette:

App background: #252525

Note colors:
- #FD99FF
- #FF9E9E
- #91F48F
- #FFF599
- #9EFFFF
- #B69CFF

Delete action:
- #FF0000

Favorite action:
- #FFD700

Common dark surfaces:
- #454545
- #3B3B3B

Do not replace these with Material theme approximations.

---

# Swipe interaction

The Figma represents swipe actions as REVEALED ACTIONS, not automatic destructive
swipe-to-dismiss behavior.

Do not use Dismissible.

## Resting state

At offset 0:

- only the note card is visible;
- no red background is visible;
- no yellow background is visible;
- no action icon is visible;
- this must remain true even if the note has a very short title/body.

The foreground note must cover the entire row width.

The action layer must be behind the note using the same row bounds.

## Swipe left — delete

Dragging left reveals a RED action area on the RIGHT.

The trash icon is centered inside the revealed action area.

Crossing the drag threshold DOES NOT delete the note.

When the reveal threshold is reached, release should settle the row into its
open/revealed position.

The user must TAP the revealed delete action/trash icon to actually delete.

A partial drag below threshold returns to the closed position.

Tapping elsewhere or opening another row closes the currently open row.

Deletion occurs only from a deliberate tap on the revealed delete action.

## Swipe right — favorite

Dragging right reveals a YELLOW action area on the LEFT.

The star icon is centered inside the revealed yellow action area.

Use the same reveal model as delete.

Prefer reveal-then-tap rather than executing favorite merely because a drag
passed a threshold.

After favorite toggles, close the row.

## Geometry

The background action layer fills the exact full bounds of the note row.

The note foreground also fills the exact full width.

Do not size either layer from text intrinsic dimensions.

Use constraints from the list parent.

The action width should be fixed and visually matched to the Figma rather than
growing based on drag distance indefinitely.

Clip the complete interaction to the same outer rounded shape where necessary.

---

# Buttons and touch feedback

Do not accept default Material visual behavior merely because a Flutter widget
provides it.

The Figma does not show large circular Material splash effects.

For custom dark square/rounded controls:

- the visible control bounds must match the Figma;
- tap feedback must remain inside those bounds;
- circular ripple must never extend outside the button background;
- do not allow an IconButton splash to paint beyond a rounded-square parent.

Prefer one of:

1. a clipped contained InkWell with matching border radius; or
2. a custom button with subtle pressed opacity; or
3. IconButton with Material overlay/splash disabled where appropriate.

Do not globally introduce visible Material ripples where the Figma has none.

Maintain a reasonable invisible touch target without increasing the visible
button size.

---

# Sizing

Do not use default Material sizing unless it matches the reference.

In particular check manually:

- header horizontal padding
- distance from title to top controls
- square control dimensions
- icon dimensions
- note-card width
- note-card internal padding
- space between cards
- card corner radius
- filter-chip height and spacing
- FAB diameter and distance from screen edges
- editor top controls
- dialog width / internal spacing
- reader margins

Do not fix visual mismatches by scaling the whole interface.

Match each component intentionally.

---

# Material defaults

Default values from these widgets are not design specifications:

- IconButton
- FloatingActionButton
- AlertDialog
- TextButton
- FilledButton
- ChoiceChip
- SearchBar
- ListTile

If they do not visually match the Figma, style them explicitly or implement the
small custom equivalent.

The app should not look like a Material demo wrapped in dark colors.

---

# Validation

Before declaring a visual task complete:

1. inspect the reference frame;
2. run the corresponding app state at the reference phone width;
3. compare them side by side;
4. inspect short and long note content;
5. verify no hidden swipe layer leaks through;
6. verify touch feedback stays within its visual parent;
7. verify the same UI still works at narrow/wide widths and increased text scale.

"Looks reasonable" is not sufficient.