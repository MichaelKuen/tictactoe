# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

## [0.9.0] — 2026-07-01 — Milestone 08: AI Difficulty + Release Prep

### Added
- `lib/game/difficulty.dart` — `Difficulty` enum: `easy`, `medium`, `hard` with `label` getter
- `AiPlayer.move(board, player, difficulty)` — unified move method:
  - **Easy** → always random (picks from empty cells)
  - **Medium** → 35 % random, 65 % minimax (makes mistakes, still plays smart)
  - **Hard** → full minimax (unbeatable — previous default)
- **Narrow layout** — `SegmentedButton<Difficulty>` (Easy / Medium / Hard) appears below the
  mode toggle when vs AI is selected
- **Wide layout sidebar** — "Difficulty" section with three `_SidebarButton`s, visible in vs AI
  mode; sidebar column now scrollable (`SingleChildScrollView`) so it never overflows on short
  screens
- 4 new unit tests in `test/game/ai_test.dart` covering all three difficulty modes and the
  full-board edge case

### Changed
- `AiPlayer.bestMove()` retained as a public helper; `AiPlayer.move()` wraps it for difficulty
- Wide sidebar: `Column` wrapped in `SingleChildScrollView` with `mainAxisSize: min` to handle
  overflow when all sections are visible simultaneously

## [0.8.0] — 2026-07-01 — Milestone 07: Games Hub

### Added
- `lib/games/game_entry.dart` — `GameEntry` data class (`name`, `tagline`, `icon`, `iconColor`,
  `playStoreId?`, `isCurrent`); computed `isReleased` and `playStoreUrl`
- `lib/games/games_catalog.dart` — `fullStackShackGames` list (Tic Tac Toe current + coming-soon
  placeholder) and `devPageUrl` pointing to FullStackShack's Google Play developer page
- `lib/ui/games_sheet.dart` — `GamesSheet` draggable bottom sheet (65 % initial height);
  `DraggableScrollableSheet` with `_GameCard` rows (icon bubble + name/tagline + action badge),
  "View all on Google Play" footer button, house-ads disclosure text
- `url_launcher: ^6.3.2` dependency for opening Play Store links
- `Icons.sports_esports` AppBar button → opens `GamesSheet` (narrow and wide layouts)
- "More Games" `OutlinedButton.icon` in wide sidebar → also opens `GamesSheet`
- HTTPS intent query added to `AndroidManifest.xml` for `url_launcher`

### Notes
- Tic Tac Toe card shows a "Playing" badge; coming-soon games show "Soon" badge; released
  external games show a "Play" `FilledButton` that deep-links to their Play Store listing
- House-ads note at the bottom of the sheet informs users why FullStackShack ads may appear

## [0.7.0] — 2026-07-01 — Milestone 06: Polish

### Added
- `lib/theme_notifier.dart` — global `ValueNotifier<ThemeMode>` shared between `main.dart`
  and `GameScreen`
- **Light / dark theme toggle** — sun/moon icon button in the AppBar; persists for the session
- **Light theme** — deep red X (`#D32F2F`), deep blue O (`#1565C0`), off-white background;
  fully contrasting on both themes
- **Cell bounce animation** — `CellWidget` is now a `StatefulWidget` with two
  `AnimationController`s: piece placement scales in with `Curves.elasticOut` (400 ms bounce)
- **Winning cell pulse** — highlighted cells gently scale 1.0 → 1.05 and back on a 700 ms
  repeat (`Curves.easeInOut`)
- **Status text crossfade** — `AnimatedSwitcher` wraps the status text; changes fade out/in
  over 250 ms
- **Haptic feedback** — `HapticFeedback.selectionClick()` on every move (player and AI);
  `lightImpact` on draw; `mediumImpact` on win
- `_darkTheme` / `_lightTheme` split in `main.dart`; `MaterialApp` consumes both via
  `themeMode`
- Sidebar border and background are now theme-aware (dark navy in dark mode, light grey in
  light mode)

### Changed
- `CellWidget` — converted `StatelessWidget` → `StatefulWidget`; controllers initialised in
  `initState()` (not lazily) to avoid deactivated-ancestor errors during `AnimatedSwitcher`
  transitions
- `CellWidget` cell background is now `Colors.white` in light mode, `Color(0xFF252540)` in
  dark mode (`isDark` check)
- `test/ui/game_screen_test.dart` — test wrapper now forces `Brightness.dark` so existing
  colour assertions remain valid

## [0.6.0] — 2026-07-01 — Milestone 05: AdMob Integration

### Added
- `google_mobile_ads: ^9.0.0` dependency
- `lib/ads/ad_manager.dart` — singleton `AdManager`: initialises SDK, loads and cycles
  interstitial (every 3rd game) and rewarded (on demand) ads; platform-gated so web/desktop
  are unaffected
- **Banner ad** — pinned to `Scaffold.bottomNavigationBar`; loads automatically on Android/iOS
  using Google's test banner unit ID
- **Interstitial ad** — shown automatically after every 3rd game over (win or draw); preloaded
  and reloaded in the background
- **Rewarded video ad** — "Watch ad for hint" button appears while a game is in progress;
  completing the ad highlights the optimal cell in green (`#69F0AE`) via `AiPlayer.bestMove`
- `CellWidget.hinted` param — green tint + border to indicate the hinted cell
- `BoardWidget.hintCell` param (int?) — passed through to `CellWidget`
- `INTERNET` permission and AdMob `APPLICATION_ID` meta-data added to `AndroidManifest.xml`
- `WidgetsFlutterBinding.ensureInitialized()` + async `AdManager.initialize()` in `main()`

### Notes
- All ad unit IDs are Google's official **test IDs** — swap for real IDs before release
- Ads are suppressed on Web and Windows (`kIsWeb` / `defaultTargetPlatform` guard)
- See [docs/admob_setup_guide.md](docs/admob_setup_guide.md) for the full production setup walkthrough

## [0.5.0] — 2026-07-01 — Milestone 04: AI Player & UI Polish

### Added
- `lib/game/ai.dart` — `AiPlayer.bestMove()` using minimax algorithm; unbeatable O player
- `test/game/ai_test.dart` — AI test suite (wins, blocks, never loses exhaustive coverage)
- `lib/ui/game_screen.dart` — vs AI / vs Human mode toggle via `SegmentedButton`
- Responsive layout: `LayoutBuilder` breakpoint at 600 px — wide screens (Windows/Web) show
  centered board with right-side sidebar menu (mode buttons + New Game); narrow screens keep
  stacked column layout

### Changed
- `lib/main.dart` — switched to `ColorScheme.dark()` with vivid red primary (X) and sky-blue
  secondary (O) on dark navy background for high contrast
- `lib/ui/cell_widget.dart` — cells now have a permanent dark fill (`#252540`); winning cells
  highlight in amber (`#FFD740` tint + border) instead of `primaryContainer`
- `lib/ui/game_screen.dart` — AppBar uses dark surface colour; wide layout adds `_SidebarButton`
  private widget for mode selection
- `test/ui/game_screen_test.dart` — updated colour assertions to match new cell background

## [0.4.0] — 2026-06-25 — Milestone 03: Win Detection UI

### Added
- `Board.winningLine` getter — returns `List<int>?` of the 3 winning cell indices, or null
- `CellWidget.highlighted` param — draws `primaryContainer` background and `primary` border on winning cells
- 5 new `Board.winningLine` unit tests
- 2 new widget tests (winning cells highlighted, no highlight mid-game)

### Changed
- `BoardWidget` — accepts `winningLine` and forwards `highlighted` to each `CellWidget`
- `GameScreen` — passes `_game.board.winningLine` to `BoardWidget`

## [0.3.0] — 2026-06-25 — Milestone 02: Basic UI

### Added
- `lib/ui/game_screen.dart` — `GameScreen` StatefulWidget: holds `Game` state, shows status text and reset button
- `lib/ui/board_widget.dart` — `BoardWidget`: 3×3 `GridView` that delegates taps via `onCellTap`
- `lib/ui/cell_widget.dart` — `CellWidget`: bordered cell rendering X/O with theme colours
- `test/ui/game_screen_test.dart` — 5 widget tests: turn indicator, place X, occupied-cell no-op, reset, X wins message

### Changed
- `lib/main.dart` — replaced Flutter counter scaffold with `TicTacToeApp` (Material 3, indigo seed)
- `test/widget_test.dart` — replaced counter smoke test with app smoke test

## [0.2.0] — 2026-06-11 — Milestone 01: Game Logic

### Added
- `lib/game/player.dart` — `Player` enum (x, o) with `opponent` getter and `label`
- `lib/game/board.dart` — immutable `Board`: 9-cell grid, `canMove`, `move`, `winner`, `isDraw`, `isTerminal`, `emptyCells`
- `lib/game/game_status.dart` — `GameStatus` enum: playing, xWins, oWins, draw
- `lib/game/game.dart` — immutable `Game` state machine: `move()`, `reset()`, `isOver`
- `test/game/board_test.dart` — 30 tests covering all Board behaviour
- `test/game/game_test.dart` — 22 tests covering full game flows (win, draw, reset, no-ops)

## [0.1.0] — 2026-06-11 — Milestone 00: Project Setup

### Added
- Flutter project scaffold (com.fullstackshack.tictactoe)
- CLAUDE.md — AI session guide, templates, and milestone plan
- README.md — project overview, structure, and milestone table
- BUILD_LOG.md — command history log
- CHANGELOG.md — this file
- docs/milestone_00_setup.md — milestone completion record
- Copyright headers on all .dart files in lib/ and test/
- Git repository initialised on `main` branch with milestone/00-project-setup branch

### Changed
- App bundle ID updated from com.example.tictactoe to com.fullstackshack.tictactoe across all platforms
- pubspec.yaml description updated to reflect project purpose
