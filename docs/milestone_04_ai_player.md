# Milestone 04 — AI Player & UI Polish

**Date:** 2026-07-01
**Branch:** milestone/04-ai-player
**Status:** Complete

## Objectives

- [x] Implement minimax AI opponent (`AiPlayer.bestMove`)
- [x] Add vs AI / vs Human mode toggle
- [x] AI takes its turn automatically with a 300 ms delay
- [x] High-contrast colour theme (dark navy, red X, sky-blue O, amber winning highlight)
- [x] Responsive layout — wide screens (Windows/Web) centre the board and place controls in a right sidebar
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 76/76 pass

## Key decisions

**Minimax with no depth limit** — board is small enough (9 cells, max 9 moves) that exhaustive search is instant; no pruning needed.

**`ColorScheme.dark()` with explicit primary/secondary** — gave full control over X (red) and O (cyan) colours without fighting Material seed generation.

**`LayoutBuilder` at 600 px** — covers Windows desktop and wide browser windows; mobile stays on the existing column layout unchanged.

**Mirror spacer** — a `SizedBox(width: sidebarWidth)` on the left of the wide layout row keeps the board optically centred without a nested `Center`.

## Notes

Two widget tests that previously asserted `decoration.color == null` for non-highlighted cells were updated to assert `Color(0xFF252540)` (the new permanent cell fill).
