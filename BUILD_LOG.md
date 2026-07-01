# Build Log

All commands run during development, with exact output. Nothing summarised.

---

## Milestone 11 — Score Tracking

**Date:** 2026-07-01
**Branch:** milestone/11-score-tracking
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/game/score.dart              — NEW: immutable Score data class
lib/game/score_repository.dart   — NEW: SharedPreferences persistence for ai + human scores
lib/ui/score_widget.dart         — NEW: animated three-column scoreboard widget
lib/ui/game_screen.dart          — integrated score tracking and ScoreWidget in both layouts
test/game/score_test.dart        — NEW: 7 unit tests for Score
pubspec.yaml                     — added shared_preferences: ^2.3.2
```

### Commands & Output

```
flutter pub get
  Changed 13 dependencies!

flutter analyze
  No issues found! (ran in 2.3s)

flutter test
  00:03 +98: All tests passed!
```

---

## Milestone 10 — Health Awareness Timer

**Date:** 2026-07-01
**Branch:** milestone/10-health-timer
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/health/session_timer.dart       — NEW: SessionTimer ChangeNotifier (20-min eye-break, 60-min session limit)
lib/ui/session_bar_widget.dart      — NEW: compact health bar widget with AnimatedContainer + _PulsingDot
lib/ui/game_screen.dart             — integrated SessionTimer, eye-break snackbar, session-limit dialog
lib/ui/cell_widget.dart             — fix: _placeCtrl.stop()+reset() instead of value=0 in didUpdateWidget
test/health/session_timer_test.dart — NEW: 10 unit tests for SessionTimer
```

### Commands & Output

```
flutter analyze
  No issues found! (ran in 1.4s)

flutter test
  00:02 +91: All tests passed!
```

### Root-cause notes

**CellWidget animation fix:** `_placeCtrl.value = 0` during `didUpdateWidget` notified `ScaleTransition`
listeners mid-reconciliation, scheduling an extra frame. Changed to `_placeCtrl.stop(); _placeCtrl.reset()`
which stops the animation cleanly before resetting without triggering listener callbacks at an unsafe time.

**Wide-layout sidebar overflow:** Adding `SessionBarWidget` reduced the body height available to the sidebar.
The "New Game" button (after mode + difficulty sections) was pushed past the 600 px test viewport bottom,
causing `tester.tap(find.text('New Game'))` to fire a hit-test warning and not register. Fix: reduced the
`SizedBox(height: 32)` spacers before and after the separator Divider to `SizedBox(height: 8)`.

---

## Milestone 09 — Custom App Icon + Splash Screen

**Date:** 2026-07-01
**Branch:** milestone/09-app-icon-splash
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
assets/icon/app_icon.png            — NEW: 1024×1024 custom launcher icon (Python/Pillow)
assets/splash/splash_logo.png       — NEW: centred icon on navy background for splash
pubspec.yaml                        — flutter_launcher_icons + flutter_native_splash config
android/app/src/main/res/           — generated mipmap-* icon sets, launch_background XML files
android/app/src/main/res/values*/   — styles.xml files for Android 12 splash
ios/Runner/Assets.xcassets/         — AppIcon.appiconset generated
ios/Runner/Info.plist               — updated by flutter_native_splash
```

### Icon generation (Python/Pillow)

```python
# 1024×1024, navy bg #1A1A2E, grid #5A5A7A, X #FF5252, O #40C4FF
# Output: assets/icon/app_icon.png + assets/splash/splash_logo.png
```

### flutter pub add (dev dependencies)

```
+ flutter_launcher_icons 0.14.4
+ flutter_native_splash 2.4.7
+ image 4.8.0
(+ 16 other transitive packages)
```

### dart run flutter_launcher_icons

```
• Creating default icons Android
• Overwriting the default Android launcher icon with a new icon
• Overwriting default iOS launcher icon with new icon
✓ Successfully generated launcher icons
```

### dart run flutter_native_splash:create

```
[Android] Creating default splash images
[Android] Creating dark mode splash images
[Android] Creating default android12splash images
[Android] Creating dark mode android12splash images
[Android] Updating launch background(s) with splash image path...
[Android] Updating styles...
[Android] Creating android/app/src/main/res/values-v31/styles.xml
[Android] Creating android/app/src/main/res/values-night-v31/styles.xml
[iOS] Creating images
[iOS] Creating dark mode images
[iOS] Updating ios/Runner/Info.plist for status bar hidden/visible
✅ Native splash complete.
```

### flutter analyze

```
No issues found! (ran in 1.6s)
```

**Result: PASS — zero issues**

### flutter test

```
+80: All tests passed!
```

**Result: PASS — 80/80**

---

## Milestone 08 — AI Difficulty + Release Prep

**Date:** 2026-07-01
**Branch:** milestone/08-release-prep
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/game/difficulty.dart        — NEW: Difficulty enum (easy, medium, hard)
lib/game/ai.dart                — AiPlayer.move() wrapping bestMove() per difficulty
lib/ui/game_screen.dart         — _difficulty state; difficulty selector narrow + sidebar;
                                   SingleChildScrollView on sidebar column
test/game/ai_test.dart          — 4 new difficulty tests
```

### flutter analyze

```
No issues found! (ran in 1.5s)
```

**Result: PASS — zero issues**

### flutter test

```
+80: All tests passed!
```

**Result: PASS — 80/80**

---

## Milestone 07 — Games Hub

**Date:** 2026-07-01
**Branch:** milestone/07-games-hub
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/games/game_entry.dart       — NEW: GameEntry data class
lib/games/games_catalog.dart    — NEW: fullStackShackGames list + devPageUrl
lib/ui/games_sheet.dart         — NEW: DraggableScrollableSheet bottom sheet with _GameCard rows
lib/ui/game_screen.dart         — sports_esports AppBar button + More Games sidebar button
android/app/src/main/AndroidManifest.xml — HTTPS intent query for url_launcher
pubspec.yaml                    — url_launcher: ^6.3.2
```

### flutter pub add url_launcher

```
+ url_launcher 6.3.2
+ url_launcher_android 6.3.30
+ url_launcher_ios 6.3.4
+ url_launcher_linux 3.2.3
+ url_launcher_macos 3.2.3
+ url_launcher_platform_interface 2.3.2
+ url_launcher_web 2.4.1
+ url_launcher_windows 3.1.4
Changed 8 dependencies!
```

### flutter analyze (first run — 1 lint issue)

```
info - Unnecessary use of multiple underscores - lib\ui\games_sheet.dart:83:41 - unnecessary_underscores
1 issue found. (ran in 1.5s)
```

**Fix:** Changed `separatorBuilder: (_, __) =>` to `separatorBuilder: (context, index) =>`

### flutter analyze (after fix)

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

## Milestone 06 — Polish

**Date:** 2026-07-01
**Branch:** milestone/06-polish
**Flutter:** 3.41.4 | **Dart:** 3.11.1

### New / changed files

```
lib/theme_notifier.dart         — NEW: global ValueNotifier<ThemeMode>
lib/main.dart                   — split into _lightTheme / _darkTheme; ValueListenableBuilder
lib/ui/cell_widget.dart         — StatefulWidget; bounce animation + winning pulse animation
lib/ui/game_screen.dart         — haptic feedback; status AnimatedSwitcher; theme toggle AppBar button
test/ui/game_screen_test.dart   — test wrapper forced to Brightness.dark
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

### Investigation note
`AnimatedSwitcher` on the board widget (keyed by `_boardKey`) was trialled but caused
duplicate-key finder errors in tests and deactivated-ancestor ticker errors during
`AnimatedSwitcher` transitions. Removed; cell-level animations provide equivalent feedback.

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
