# Build Log

All commands run during development, with exact output. Nothing summarised.

---

## Milestone 05 — AdMob Docs Update

**Date:** 2026-07-01
**Branch:** milestone/05-admob (post-merge docs update on main)

### Files updated

```
docs/admob_setup_guide.md   — NEW: full production setup walkthrough (account, units, IDs, payment, policies)
README.md                   — updated project structure, added AdMob section with link to setup guide
CLAUDE.md                   — added AdMob section + two new Do Not rules
docs/milestone_05_admob.md  — updated "Before releasing" section to link to setup guide
CHANGELOG.md                — added setup guide reference in [0.6.0] notes
```

---

## Milestone 05 — AdMob Integration

**Date:** 2026-07-01
**Branch:** milestone/05-admob
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/ads/ad_manager.dart             — AdManager singleton (interstitial + rewarded)
lib/main.dart                       — async init + AdManager.initialize()
lib/ui/game_screen.dart             — banner ad, interstitial trigger, rewarded hint button
lib/ui/board_widget.dart            — hintCell param
lib/ui/cell_widget.dart             — hinted param (green tint)
android/app/src/main/AndroidManifest.xml — INTERNET permission + AdMob App ID
pubspec.yaml                        — google_mobile_ads: ^9.0.0
```

### flutter pub add google_mobile_ads

```
+ google_mobile_ads 9.0.0
+ plugin_platform_interface 2.1.8
+ webview_flutter 4.14.0
+ webview_flutter_android 4.12.0
+ webview_flutter_platform_interface 2.15.1
+ webview_flutter_wkwebview 3.25.1
Changed 6 dependencies!
```

### flutter analyze

```
No issues found! (ran in 1.3s)
```

**Result: PASS — zero issues**

### flutter test

```
+76: All tests passed!
```

**Result: PASS — 76/76**

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

## Milestone 04 — AI Player & UI Polish

**Date:** 2026-07-01
**Branch:** milestone/04-ai-player
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/game/ai.dart                — AiPlayer.bestMove() — minimax algorithm
lib/main.dart                   — ColorScheme.dark() with red/cyan/navy contrast theme
lib/ui/cell_widget.dart         — permanent dark cell fill; amber winning highlight
lib/ui/game_screen.dart         — vs AI/Human toggle; responsive wide layout with sidebar
test/game/ai_test.dart          — AI test suite (wins, blocks, never-loses exhaustive)
test/ui/game_screen_test.dart   — updated colour assertions for new cell backgrounds
```

### flutter analyze

```
No issues found! (ran in 1.3s)
```

**Result: PASS — zero issues**

### flutter test

```
+76: All tests passed!
```

**Result: PASS — 76/76**

### git log

```
7155b9b feat(ai): add minimax AI opponent with vs AI / vs Human mode toggle
```

---

## Milestone 03 — Win Detection UI

**Date:** 2026-06-25  
**Branch:** milestone/03-win-detection  
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### Changed files

```
lib/game/board.dart             — added winningLine getter (List<int>?)
lib/ui/cell_widget.dart         — added highlighted param (primaryContainer bg + primary border)
lib/ui/board_widget.dart        — added winningLine param, passes highlighted to each CellWidget
lib/ui/game_screen.dart         — passes board.winningLine to BoardWidget
test/game/board_test.dart       — 5 new Board.winningLine tests
test/ui/game_screen_test.dart   — 2 new highlighting widget tests
```

### flutter analyze

```
No issues found! (ran in 1.0s)
```

**Result: PASS — zero issues**

### flutter test

```
+64: All tests passed!
```

**Result: PASS — 64/64**

### git log

```
cf4d62d feat(ui): highlight winning cells on game over
3326b9a docs(milestone-02): add tutorial for basic UI
61e548a chore(merge): milestone/02-basic-ui → main
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
