# Figma Reference Geometry

These measurements are derived from the supplied rendered Figma reference,
not Dev Mode metadata.

Reference viewport for normal frames:

393 × 852 logical units

Do not treat these as universal fixed dimensions. They are the calibration
target at the reference width. Responsive layouts should preserve the visual
relationships at other widths.

## Verified typography

These values were read directly from Figma and are authoritative. Nunito is
bundled locally and is the application-wide font family; platform-default fonts
must not be substituted.

| Element | Weight | Size | Line height | Letter spacing |
|---|---:|---:|---:|---:|
| Home `Notes` heading | 600 | 43 | 100% | 0% |
| Note/card text | 400 | 25 | 100% | 0% |
| Selected filter | 700 | 16 | 100% | 0% |
| Unselected filter | 600 | 16 | 100% | 0% |
| Editor title and title placeholder | 400 | 48 | 100% | 0% |
| Editor body and body placeholder | 400 | 23 | 100% | 0% |
| Empty-state caption | 300 | 20 | 100% | 0% |

Other text keeps its existing size and weight while inheriting Nunito. Do not
invent exact typography values for layers that have not been measured.

## Global horizontal layout

Primary content/card inset:
approximately 23

Normal full note width at reference viewport:
approximately 348

Do not use 16 as the default page inset simply because it is a common Material
value.

## Header controls

Search/info/back/eye/save/favorite/edit shared control:
exactly 50 × 50

Corner radius:
15

Graphical icon:
24 × 24

These controls must be visually square.

Do not use a narrow 30 × 56 shape.

## Note card sizing

Note cards are content-driven.

Verified internal padding:

`EdgeInsets.all(28)`

Do not impose a fixed or arbitrary minimum visual height based on the sample
screens.

Card height is determined by:

vertical padding + rendered text height

With the verified Nunito 25px / 100% line-height card text, short and wrapped
notes must naturally have different heights.

Card foreground always owns the full note width. Text wraps naturally without
truncation, and the card grows by the rendered number of lines.

The swipe action background and translated foreground must always use the same
dynamic row height.

## Favorite swipe

Reference yellow action width:
approximately 85

The yellow action layer is behind the card.

At rest:
- action layer is completely covered;
- zero yellow pixels visible.

When opened:
- yellow area is revealed on the LEFT;
- star is centered inside the approximately 85-wide action area;
- foreground card retains its full width;
- foreground is translated right by approximately 85;
- foreground is clipped by the row bounds;
- DO NOT shrink foreground width to `rowWidth - actionWidth`.

The reference frame shows approximately 25% action / 75% visible card, but the
card itself remains full width.

## Delete swipe

Delete is intentionally different from favorite.

Frame 03 shows:
- full-width red action state;
- no note foreground visible;
- trash icon centered in the COMPLETE row.

Swipe left should move the complete note foreground off the row.

After a successful reveal:
- red fills the entire original note bounds;
- trash is centered horizontally and vertically;
- the note is not deleted merely because it crossed a drag threshold.

Require a deliberate tap on the revealed red/trash action to delete.

Allow the user to close/cancel the revealed state.

Do not implement this as the same 85-wide reveal used for favorite.

## FAB

Reference FAB visual diameter:
approximately 66

Its position is near the bottom-right with a comfortable edge inset.

Do not use the current approximately 39-wide visual FAB.

## Filter view

Filters are LEFT ALIGNED, not centered.

Selected filter typography:
- Nunito 700
- size 16
- line height 1.0
- letter spacing 0

Unselected filter typography:
- Nunito 600
- size 16
- line height 1.0
- letter spacing 0

Approximate reference:

All:
- x: 23
- width: 50

Favorites:
- x: 82
- width: 94

Recent:
- x: 184
- width: 78

Chip height:
approximately 35

Spacing is compact.

Do not add exaggerated letter spacing.

## Search

Search field:

x:
approximately 30

width:
approximately 341

height:
approximately 45

The current field height is already close.

The field should not extend almost edge-to-edge.

## Empty state

Illustration:

x:
approximately 37

y:
approximately 279

width:
approximately 320

height:
approximately 256

At reference width the illustration should be substantially larger than the
current implementation.

The message sits shortly below the illustration.

Do not vertically center the illustration/message group using generic `Center`
or `Spacer` behavior if it moves it away from the reference position.

## Dialog

Save/discard dialog reference:

x:
approximately 40

top:
approximately 314

width:
approximately 313

height:
approximately 225

The current implementation is much too vertically compressed.

Reference action button size is approximately:

width:
105

height:
37

Do not stretch both buttons to consume nearly half of the complete dialog width
each.

## Responsive rule

At 393 × 852, match these calibration values closely.

At other widths:
- preserve proportional margins where sensible;
- allow text/card heights to grow;
- maintain usable touch targets;
- avoid scaling the entire screen as one bitmap.

The reference geometry is a baseline, not a reason to break responsiveness.
