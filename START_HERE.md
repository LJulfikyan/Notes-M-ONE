# Notes M-ONE — Starter Pack

Repository: `https://github.com/LJulfikyan/Notes-M-ONE`

This pack is intended to be extracted into the repository root before the first Codex implementation task.

## What is in the pack

Committed/project guidance:
- `AGENTS.md` — standing instructions for Codex while developing.
- `AI/context.md` — the required challenge context brief; keep it accurate as the code evolves.
- `README.md` — starter submission README with sections that must be finalized.
- `docs/CHALLENGE_SUMMARY.md` — source-grounded challenge requirements.
- `docs/DESIGN_REFERENCE.md` — what is actually known from the supplied Figma and screenshots.
- `docs/DESIGN_NOTES_DRAFT.md` — contradictions/gaps and chosen resolutions.
- `docs/ARCHITECTURE.md` — intended small architecture.

Local-only material:
- `.codex_reference/` — original challenge PDF, native `.fig`, rendered overview, extracted illustrations, Figma thumbnail and device reference images.
- `.codex_prompts/` — ordered Codex implementation prompts.

The local-only directories should be ignored by Git. Prompt 01 creates/appends the required `.gitignore` entries.

## Important Figma rule

The native `design.fig` is included so Codex can access the original file bytes locally, but **do not rely on Codex being able to decode the native Figma node tree perfectly**. The reliable references are:
1. `.codex_reference/overview.png`
2. `.codex_reference/figma_thumbnail.png`
3. `.codex_reference/assets_sheet.jpg`
4. the extracted PNG illustrations
5. `docs/DESIGN_REFERENCE.md`

The `.fig` remains useful as provenance and can be inspected if the environment has a compatible parser, but an agent must not claim exact node measurements/fonts/vector paths unless it actually extracts them.

## Run order

Run one prompt at a time in the same local Codex thread or successive local threads:

1. `.codex_prompts/01_bootstrap.md`
2. `.codex_prompts/02_data_and_state.md`
3. `.codex_prompts/03_home_and_filter.md`
4. `.codex_prompts/04_custom_swipe.md`
5. `.codex_prompts/05_search.md`
6. `.codex_prompts/06_editor_and_drafts.md`
7. `.codex_prompts/07_reader_and_dialogs.md`
8. `.codex_prompts/08_resilience_and_tests.md`
9. `.codex_prompts/09_visual_audit.md`
10. `.codex_prompts/10_submission_docs.md`

Each prompt is deliberately medium-sized and has a hard stop. Do not ask Codex to continue into the next prompt automatically.

## Parallel work

For this challenge, sequential work is safer because the app is small and the UI pieces share the same model/store/theme. If you parallelize, do it only **after Prompt 02 is merged**, and use separate worktrees. Home/filter, search, and editor can then be attempted independently, but merge conflicts and inconsistent visual decisions are still possible.

## Final manual work

After Prompt 10:
- fill the applying level in `README.md`;
- inspect the app yourself on at least the devices/settings listed in the README;
- make the required unedited ~3-minute screen recording;
- push the final branch to the public GitHub repository.
