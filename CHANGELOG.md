# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

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
