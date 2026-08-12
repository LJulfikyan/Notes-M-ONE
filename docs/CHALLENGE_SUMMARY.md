# Challenge Summary

Source: supplied `Test Task. Flutter.pdf`.

## Build

- Build the Notes app from scratch; there is no starter repo.
- Implement design frames 01–14.
- Frames 05 and 06 are alternative answers to the same question; implement only one and explain the choice in README.
- This project chooses **06 — Filter View**.
- Notes contain a plain-string title and body.
- No rich-text, markdown, or formatting model.
- The editor toolbar drawn in frame 09 is not functional; it may be static or omitted.
- Persist data locally.
- State management is the candidate's choice and must be explained.

## Production behavior

The result should behave like a shipped app:
- gestures should not fight;
- animations should survive interruption;
- data should not be lost when the process is killed.

## Responsiveness

The design is drawn at one old phone width and one text size. The implementation must handle:
- other widths;
- content that wraps;
- larger text settings;
- content that the design does not show;
- no unusable or stranded layout on wider screens.

The README must state which devices/settings were checked and how.

## Design gaps

The task explicitly says the design contains gaps, contradictions and mistakes. These should be named in README instead of silently hidden.

## UI restriction

- No third-party packages for the UI.
- Flutter `Dismissible` is explicitly forbidden.

## Tests

Tests are optional, but meaningful tests are valued.
The task specifically highlights a widget test rendering the list across:
- multiple widths;
- multiple text scales;
- multiple content states.

Goldens are useful if committed.
A token test that only pumps/asserts nothing is worse than deliberately skipping tests.

## Required context brief

Commit `AI/context.md` (or equivalent format requested by the task) containing the real briefing an assistant would need:
- conventions;
- architecture;
- traps;
- things an agent should never do.

The evaluators may run their own agent on an unseen task in the repo using this briefing.

## Submission

Public GitHub repo containing:
- `README.md`;
- applying level;
- run instructions;
- state-management choice and reason;
- `What is still wrong with this`;
- `Design notes`;
- `AI/context.md`;
- any tests;
- real Git history whose commits match their diffs.

Also provide an unedited ~3-minute screen recording of yourself working on any part of the project and talking through it.

## Out of scope

- the unchosen 05/06 alternative;
- backend;
- sync;
- auth;
- tags;
- folders;
- design-system work.

A small feature done well is preferable to a larger half-built feature.
