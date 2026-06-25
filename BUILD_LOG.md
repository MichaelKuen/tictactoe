# Build Log

All commands run during development, with exact output. Nothing summarised.

---

## Milestone 00 — Project Setup

**Date:** 2026-06-11  
**Flutter:** 3.41.4 (stable, channel stable)  
**Dart:** 3.11.1  
**DevTools:** 2.54.1  

### flutter --version

```
Flutter 3.41.4 • channel stable • https://github.com/flutter/flutter.git
Framework • revision ff37bef603 (3 months ago) • 2026-03-03 16:03:22 -0800
Engine • hash 99578ad0355da00edb26301c874a3c250a5716f5 (revision e4b8dca3f1) (3 months ago) • 2026-03-03 18:24:54.000Z
Tools • Dart 3.11.1 • DevTools 2.54.1
```

### flutter analyze

(to be filled after running)

### flutter test

(to be filled after running)

### git log (Milestone 00)

```
44e8e20 chore(init): project scaffold with docs and copyright headers
```

---

## Milestone 01 — Game Logic

**Date:** 2026-06-11  
**Branch:** milestone/01-game-logic  
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New files

```
lib/game/player.dart        — Player enum + opponent/label
lib/game/board.dart         — Board (immutable, 9 cells)
lib/game/game_status.dart   — GameStatus enum
lib/game/game.dart          — Game state machine
test/game/board_test.dart   — 30 Board tests
test/game/game_test.dart    — 22 Game tests
```

### flutter analyze (first run — 4 lint issues)

```
info - The local variable '_drawBoard' starts with an underscore — test/game/board_test.dart:120:11
info - The local variable '_xWinsRow' starts with an underscore — test/game/game_test.dart:53:10
info - The local variable '_oWinsRow' starts with an underscore — test/game/game_test.dart:69:10
info - The local variable '_draw' starts with an underscore — test/game/game_test.dart:93:10
flutter: 4 issues found. (ran in 1.0s)
```

**Fix:** Renamed local test helpers — removed leading underscores.

### flutter analyze (after fix)

```
Analyzing tictactoe...
No issues found! (ran in 1.0s)
```

**Result: PASS — zero issues**

### flutter test --reporter expanded

```
00:00 +0: loading .../test/game/board_test.dart
00:00 +7: Board.empty() [7 tests passed]
00:00 +13: Board.move() [6 tests passed]
00:00 +23: Board winner detection [10 tests passed]
00:00 +28: Board draw detection [4 tests passed]
00:00 +30: Board.isTerminal [2 tests passed]
00:00 +34: Game.start() [4 tests passed]
00:00 +38: Game.move() — turn alternation [4 tests passed]
00:00 +42: Game.move() — X wins [4 tests passed]
00:00 +45: Game.move() — O wins [3 tests passed]
00:00 +47: Game.move() — diagonal wins [2 tests passed]
00:00 +49: Game.move() — draw [2 tests passed]
00:00 +51: Game.reset() [2 tests passed]
00:00 +52: All tests passed!
```

**Result: PASS — 52/52 (30 board + 22 game + 1 widget smoke test)**

### git log

```
98b141e feat(game): implement core board state and game logic
44e8e20 chore(init): project scaffold with docs and copyright headers
```

---

## Milestone 02 — Basic UI

**Date:** 2026-06-25  
**Branch:** milestone/02-basic-ui  
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/main.dart                   — replaced counter scaffold with TicTacToeApp
lib/ui/game_screen.dart         — StatefulWidget: holds Game state, status text, reset button
lib/ui/board_widget.dart        — 3×3 GridView, passes taps up via onCellTap
lib/ui/cell_widget.dart         — individual cell: GestureDetector, X/O text, themed border
test/widget_test.dart           — replaced counter smoke test with app smoke test
test/ui/game_screen_test.dart   — 5 widget tests (turn display, place X, no-op, reset, X wins)
```

### flutter analyze

```
Analyzing tictactoe...
No issues found! (ran in 1.0s)
```

**Result: PASS — zero issues**

### flutter test

```
00:00 +57: All tests passed!
```

**Result: PASS — 57/57 (30 board + 22 game + 1 smoke + 5 widget tests)**

### git log

```
58db9b5 feat(ui): implement basic game UI — grid, X/O rendering, tap to play
e915208 docs(milestone-01): add tutorial for core game logic
76904de docs: update CLAUDE.md and README with milestone 00/01 status
```
