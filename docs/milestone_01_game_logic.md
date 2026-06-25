# Milestone 01 — Game Logic

**Date:** 2026-06-11  
**Branch:** milestone/01-game-logic  
**Status:** Complete — awaiting user confirmation

---

## Objectives

- [x] Create `lib/game/player.dart` — Player enum with opponent/label
- [x] Create `lib/game/board.dart` — immutable Board with full win/draw detection
- [x] Create `lib/game/game_status.dart` — GameStatus enum
- [x] Create `lib/game/game.dart` — immutable Game state machine
- [x] Write comprehensive tests — board_test.dart (30 tests), game_test.dart (22 tests)
- [x] flutter analyze — zero issues
- [x] flutter test — 52/52 pass

---

## File Map

| File | Responsibility |
|------|---------------|
| `lib/game/player.dart` | `Player` enum: x, o. `opponent` getter, `label` string |
| `lib/game/board.dart` | Immutable 9-cell board. `move()`, `canMove()`, `winner`, `isDraw`, `isTerminal`, `emptyCells` |
| `lib/game/game_status.dart` | `GameStatus` enum: playing, xWins, oWins, draw |
| `lib/game/game.dart` | Immutable `Game`. Holds board + currentPlayer + status. `move()`, `reset()`, `isOver` |

---

## Design Decisions

- **Immutable objects throughout** — `Board.move()` and `Game.move()` return new instances; originals are never mutated. This makes state management in the UI layer straightforward.
- **Silent no-ops on invalid moves** — `Game.move()` returns `this` unchanged if the index is occupied, out of range, or the game is already over. The UI will gate on `board.canMove()` before allowing a tap.
- **X always goes first** — `Game.start()` sets `currentPlayer = Player.x`.
- **Win lines are a top-level const** — defined once in `board.dart`, checked in `winner` getter.

---

## Test Coverage

### board_test.dart (30 tests)

| Group | Count |
|-------|-------|
| `Board.empty()` initial state | 7 |
| `Board.move()` placement & validation | 6 |
| Winner detection (all 8 lines + edge cases) | 10 |
| Draw detection | 4 |
| `isTerminal` | 2 |
| **Total** | **30** |

### game_test.dart (22 tests)

| Group | Count |
|-------|-------|
| `Game.start()` initial state | 4 |
| Turn alternation & no-ops | 4 |
| X wins (row + post-game no-op) | 4 |
| O wins | 3 |
| Diagonal wins | 2 |
| Draw | 2 |
| `Game.reset()` | 2 |
| **Total** | **22** |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|-----------|
| Linter: local test helpers named with leading `_` | Renamed `_drawBoard` → `drawBoard`, `_xWinsRow` → `xWinsRow`, etc. |
