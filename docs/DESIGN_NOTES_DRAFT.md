# Design Notes Draft

These are the design gaps/contradictions identified before implementation. Final README should report what was actually implemented, not blindly copy this file.

## 1. Plain text vs italic styling

The written brief requires title/body to remain plain strings with no formatting model, while later design frames visually italicize part of the body.

**Resolution:** keep the domain plain text and avoid content-specific formatting logic. Document the visual mismatch.

## 2. Formatting toolbar vs no rich text

Frame 09 draws bold/italic/list/etc. controls even though rich text is forbidden.

**Resolution:** render a static toolbar if needed for fidelity; no formatting actions and no formatting data model.

## 3. Favorite icon inconsistency

Favorite list/filter cards show outline stars, while frame 11 uses a filled yellow star for favorite editor state.

**Resolution:** treat this as an inconsistent visual language. Prefer coherent active-state behavior where feasible and document any visual deviation.

## 4. Eye control becomes a star

Frames 09/10 show an eye control in the top-right; frame 11 replaces it with a star.

The design does not explain whether these controls share a slot, change action, or represent state.

**Resolution:** preserve the shown normal/favorite states with minimal extra behavior. Do not add an undocumented toolbar row merely to solve the contradiction.

## 5. Search exit is unspecified

Search has an X inside the field but no explicit Back button.

**Resolution:** X clears the query; system/back navigation exits search.

## 6. Empty search query behavior is unspecified

Frame 07 shows the search field and otherwise blank content.

**Resolution:** an empty query shows no result list, matching frame 07.

## 7. Wrong no-results terminology

Frame 08 says `"File not found. Try searching again."` in a Notes app.

**Resolution:** preserve the copy for Figma fidelity and call out the terminology issue in README.

## 8. Save vs discard dialogs are underspecified

The design shows both:
- frame 12: `Save changes?` with `Discard` / `Save`
- frame 13: discard confirmation with `Discard` / `Keep`

It does not explain triggers.

**Resolution:**
- dirty editor Save icon -> frame 12;
- dirty editor Back -> frame 13;
- clean editor Back -> pop.

## 9. Explicit Save vs process-kill requirement

The UI implies changes are not saved until confirmation, while the brief requires nothing to be lost if the process is killed.

**Resolution:** persist an editor draft separately. Draft persistence is not the same as committing the saved note.

## 10. FAB overlaps list content in the static frame

The FAB visually overlays lower cards.

**Resolution:** preserve FAB placement but add enough bottom scroll padding so the last item can be fully scrolled above it.

## 11. Note colors have no interaction

Six card colors are visible, but there is no color picker or assignment specification.

**Resolution:** auto-cycle the six-color palette for newly created notes and persist the selected color.

## 12. Recent is undefined

Frame 06 contains a `Recent` filter without a definition.

**Resolution:** `Recent` shows all notes ordered by `updatedAt` descending. Document this as an assumption.

## 13. Destructive swipe has no recovery state

A swipe-to-delete state is drawn, but no confirmation/undo design exists.

**Resolution:** do not invent a large modal flow. Prefer deliberate thresholding and reliable gesture semantics. If an Undo snackbar is added, document it as a small shipped-app enhancement.

## 14. Figma chrome can be mistaken for UI

Frame 14 is selected in the supplied overview and therefore has a blue Figma border/title.

**Resolution:** never render it in the app.

## 15. Filter entry is unspecified

Frame 06 shows `All`, `Favorites`, and `Recent`, but the Figma does not define
an entry action or connect those filters to the Info control.

**Resolution:** treat the filters as part of populated Home. Keep Info visible
and inert rather than overloading it or inventing an unsupported destination.
