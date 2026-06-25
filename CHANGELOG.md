# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

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
