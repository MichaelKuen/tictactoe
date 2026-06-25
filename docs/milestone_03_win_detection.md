# Milestone 03 — Win Detection UI

**Date:** 2026-06-25  
**Branch:** milestone/03-win-detection  
**Status:** ✅ Complete — merge to main pending user confirmation

## Objectives

- [x] Expose winning cell indices from `Board` (`winningLine` getter)
- [x] Highlight the 3 winning cells visually (`primaryContainer` background, `primary` border)
- [x] Non-winning cells and mid-game cells remain unstyled
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — all 64 pass

## Changed files

| File | Change |
|------|--------|
| `lib/game/board.dart` | Added `winningLine` getter returning `List<int>?` |
| `lib/ui/cell_widget.dart` | Added `highlighted` bool param; applies theme highlight when true |
| `lib/ui/board_widget.dart` | Added `winningLine` param; passes `highlighted` down to each cell |
| `lib/ui/game_screen.dart` | Passes `_game.board.winningLine` to `BoardWidget` |
| `test/game/board_test.dart` | 5 new `Board.winningLine` unit tests |
| `test/ui/game_screen_test.dart` | 2 new highlighting widget tests |

## Notes

- `winningLine` reuses the same `_winLines` loop already in `winner` — no new data structure needed.
- Highlighting uses `theme.colorScheme.primaryContainer` (background) and `theme.colorScheme.primary` (border, width 2) so it re-themes automatically with any seed colour change.
- `BoardWidget` uses `winningLine?.contains(index) ?? false` — the null-aware call means no highlight when `winningLine` is null (playing or draw state).
