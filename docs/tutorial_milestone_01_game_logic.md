# Tutorial — Milestone 01: Core Game Logic

**Branch:** `milestone/01-game-logic`  
**Goal:** Build the pure Dart game logic for Tic Tac Toe — no UI, no Flutter widgets, just the rules of the game.

By the end of this tutorial you will have:
- 4 Dart source files under `lib/game/`
- 2 test files under `test/game/`
- All tests passing with zero analyzer issues

---

## Before You Start

Make sure Milestone 00 is complete. You should already have:
- A working Flutter project at `com.fullstackshack.tictactoe`
- A clean `flutter analyze` and `flutter test` run
- The copyright header on every `.dart` file in `lib/` and `test/`

Check your starting point:

```bash
flutter analyze
flutter test
```

Both should exit with no errors before you touch anything.

---

## How the Board Works (Mental Model)

A Tic Tac Toe board is a 3×3 grid. We represent it as a flat list of 9 cells, numbered 0 to 8 left-to-right, top-to-bottom:

```
0 | 1 | 2
---------
3 | 4 | 5
---------
6 | 7 | 8
```

Each cell is either empty (`null`), or occupied by a player (`X` or `O`).

There are **8 ways to win** — 3 rows, 3 columns, 2 diagonals:

```
Rows:      [0,1,2]  [3,4,5]  [6,7,8]
Columns:   [0,3,6]  [1,4,7]  [2,5,8]
Diagonals: [0,4,8]  [2,4,6]
```

---

## Design Philosophy (Read This First)

All game objects are **immutable**. Instead of changing a board in place, every operation returns a brand-new board. This makes the code safe, easy to test, and easy to reason about:

```dart
// BAD — mutating in place (do not do this)
board.cells[4] = Player.x;

// GOOD — returning a new board
final nextBoard = board.move(4, Player.x);
```

This pattern is sometimes called "value semantics." The original board is never touched, so you can always inspect what it was before the move.

---

## Step 1 — Create the Folder

Create the directory `lib/game/`. You can do this from the terminal or your IDE file explorer:

```
lib/
  game/         <-- create this
  main.dart
```

Also create the test directory:

```
test/
  game/         <-- create this
  widget_test.dart
```

---

## Step 2 — `lib/game/player.dart`

**What it does:** Defines who the two players are (`X` and `O`) and gives each one a helper to find its opponent and a display label.

**Create the file** `lib/game/player.dart`:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

enum Player { x, o }

extension PlayerX on Player {
  Player get opponent => this == Player.x ? Player.o : Player.x;
  String get label => name.toUpperCase();
}
```

**Explanation:**

- `enum Player { x, o }` — Dart enums are a fixed set of named values. Using an enum instead of a `String` or `int` means the compiler will catch typos and you can never have an invalid player value.
- `extension PlayerX on Player` — Dart extensions let you add methods to an existing type without subclassing it. Here we add two getters to `Player`.
- `get opponent` — returns the other player. The ternary `? :` means "if X then O, else X." This is used after every move to switch turns.
- `get label` — returns `"X"` or `"O"` for display. `name` is a built-in enum property that gives the lowercase identifier (`"x"` or `"o"`); `.toUpperCase()` converts it.

---

## Step 3 — `lib/game/game_status.dart`

**What it does:** Describes all four possible states a game can be in.

**Create the file** `lib/game/game_status.dart`:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

enum GameStatus { playing, xWins, oWins, draw }
```

**Explanation:**

- Four values cover every outcome: the game is still going (`playing`), X won, O won, or nobody won and the board is full (`draw`).
- Keeping this as its own file means both `board.dart` and `game.dart` can import it without circular dependencies.

---

## Step 4 — `lib/game/board.dart`

**What it does:** Holds the 9-cell grid, handles placing pieces, detects winners and draws, and lists which cells are still empty.

**Create the file** `lib/game/board.dart`:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'player.dart';

const _winLines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
  [0, 4, 8], [2, 4, 6],             // diagonals
];

class Board {
  final List<Player?> cells;

  Board._(List<Player?> cells) : cells = List.unmodifiable(cells);

  factory Board.empty() => Board._(List.filled(9, null));

  Player? operator [](int index) => cells[index];

  bool canMove(int index) =>
      index >= 0 && index < 9 && cells[index] == null;

  Board move(int index, Player player) {
    if (!canMove(index)) return this;
    final next = List<Player?>.from(cells);
    next[index] = player;
    return Board._(next);
  }

  Player? get winner {
    for (final line in _winLines) {
      final a = cells[line[0]];
      if (a != null && a == cells[line[1]] && a == cells[line[2]]) return a;
    }
    return null;
  }

  bool get isDraw => winner == null && cells.every((c) => c != null);

  bool get isTerminal => winner != null || isDraw;

  List<int> get emptyCells =>
      [for (var i = 0; i < 9; i++) if (cells[i] == null) i];

  @override
  String toString() {
    final s = cells.map((c) => c == null ? '.' : c.label).toList();
    return '${s[0]}|${s[1]}|${s[2]}\n${s[3]}|${s[4]}|${s[5]}\n${s[6]}|${s[7]}|${s[8]}';
  }
}
```

**Explanation — section by section:**

### The win lines constant

```dart
const _winLines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8],
  [0, 3, 6], [1, 4, 7], [2, 5, 8],
  [0, 4, 8], [2, 4, 6],
];
```

This is a top-level constant (outside the class) so it is created once and shared. The leading underscore `_` means it is private to this file. We hard-code all 8 winning combinations rather than computing them at runtime — the board size never changes, so this is simpler and faster.

### The private constructor and the `cells` field

```dart
final List<Player?> cells;

Board._(List<Player?> cells) : cells = List.unmodifiable(cells);
```

- `Board._` is a **named constructor** with an underscore, making it private. Code outside this file cannot call `Board._(...)` directly — it must use the factory constructors below. This enforces our immutability contract.
- `List.unmodifiable(cells)` creates a read-only wrapper so even code inside this file cannot accidentally mutate the list after construction.
- `Player?` — the question mark means the type is *nullable*: each cell holds either a `Player` or `null` (empty).

### The empty factory

```dart
factory Board.empty() => Board._(List.filled(9, null));
```

A **factory constructor** can run logic before returning an instance. Here it creates a list of 9 `null`s and passes it to the private constructor. `List.filled(9, null)` is the standard Dart way to create a list of a fixed length pre-filled with a value.

### The index operator

```dart
Player? operator [](int index) => cells[index];
```

This lets callers write `board[4]` instead of `board.cells[4]` — a small ergonomic improvement. Dart allows you to override operators like `[]`, `+`, `==`, etc.

### canMove

```dart
bool canMove(int index) =>
    index >= 0 && index < 9 && cells[index] == null;
```

Three conditions must all be true: the index is in range AND the cell is empty. Using `&&` means Dart short-circuits — if the index is out of range, it never reads `cells[index]` (which would throw).

### move

```dart
Board move(int index, Player player) {
  if (!canMove(index)) return this;
  final next = List<Player?>.from(cells);
  next[index] = player;
  return Board._(next);
}
```

- If the move is invalid, we return the **same** board instance (`this`) unchanged. The caller can check `identical(before, after)` to detect a no-op.
- `List<Player?>.from(cells)` creates a *mutable* copy of the current cells. We mutate the copy, then pass it to `Board._()` which immediately wraps it in an unmodifiable list. The original `cells` is never touched.

### winner

```dart
Player? get winner {
  for (final line in _winLines) {
    final a = cells[line[0]];
    if (a != null && a == cells[line[1]] && a == cells[line[2]]) return a;
  }
  return null;
}
```

We loop over all 8 winning lines. For each line, we grab the first cell (`a`). If `a` is not null (occupied) and both other cells in the line hold the same player, we have a winner — return them immediately. If no line matches, return `null`.

### isDraw, isTerminal, emptyCells

```dart
bool get isDraw => winner == null && cells.every((c) => c != null);

bool get isTerminal => winner != null || isDraw;

List<int> get emptyCells =>
    [for (var i = 0; i < 9; i++) if (cells[i] == null) i];
```

- `isDraw`: only a draw if there is no winner AND every cell is filled. Order matters — check winner first so a full board with a winner is not mistakenly flagged as a draw.
- `isTerminal`: the game is over if there is a winner OR a draw.
- `emptyCells`: a **collection-if** inside a list literal. For each index 0–8, include it in the result only if that cell is null. This is idiomatic Dart.

### toString

```dart
@override
String toString() {
  final s = cells.map((c) => c == null ? '.' : c.label).toList();
  return '${s[0]}|${s[1]}|${s[2]}\n${s[3]}|${s[4]}|${s[5]}\n${s[6]}|${s[7]}|${s[8]}';
}
```

Renders the board as three rows separated by newlines — useful when debugging in the terminal. A dot `.` represents an empty cell.

---

## Step 5 — `lib/game/game.dart`

**What it does:** Ties the board, the current player, and the game status together. It is the single object you hand to the UI layer in later milestones.

**Create the file** `lib/game/game.dart`:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'board.dart';
import 'game_status.dart';
import 'player.dart';

class Game {
  final Board board;
  final Player currentPlayer;
  final GameStatus status;

  const Game._({
    required this.board,
    required this.currentPlayer,
    required this.status,
  });

  factory Game.start() => Game._(
        board: Board.empty(),
        currentPlayer: Player.x,
        status: GameStatus.playing,
      );

  bool get isOver => status != GameStatus.playing;

  Game move(int index) {
    if (isOver || !board.canMove(index)) return this;

    final next = board.move(index, currentPlayer);
    final winner = next.winner;

    final GameStatus newStatus;
    if (winner == Player.x) {
      newStatus = GameStatus.xWins;
    } else if (winner == Player.o) {
      newStatus = GameStatus.oWins;
    } else if (next.isDraw) {
      newStatus = GameStatus.draw;
    } else {
      newStatus = GameStatus.playing;
    }

    return Game._(
      board: next,
      currentPlayer: newStatus == GameStatus.playing
          ? currentPlayer.opponent
          : currentPlayer,
      status: newStatus,
    );
  }

  Game reset() => Game.start();
}
```

**Explanation — section by section:**

### Fields and the private constructor

```dart
final Board board;
final Player currentPlayer;
final GameStatus status;

const Game._({
  required this.board,
  required this.currentPlayer,
  required this.status,
});
```

`Game` holds three pieces of state:
1. The current board snapshot.
2. Whose turn it is.
3. Whether anyone has won or if it is a draw.

The constructor is `const` — meaning Dart can evaluate it at compile time when all arguments are constants. Private (`_`) for the same reason as `Board` — we control how instances are created.

### Game.start()

```dart
factory Game.start() => Game._(
      board: Board.empty(),
      currentPlayer: Player.x,
      status: GameStatus.playing,
    );
```

The single entry point for a new game. X always goes first.

### move()

```dart
Game move(int index) {
  if (isOver || !board.canMove(index)) return this;

  final next = board.move(index, currentPlayer);
  final winner = next.winner;

  final GameStatus newStatus;
  if (winner == Player.x) {
    newStatus = GameStatus.xWins;
  } else if (winner == Player.o) {
    newStatus = GameStatus.oWins;
  } else if (next.isDraw) {
    newStatus = GameStatus.draw;
  } else {
    newStatus = GameStatus.playing;
  }

  return Game._(
    board: next,
    currentPlayer: newStatus == GameStatus.playing
        ? currentPlayer.opponent
        : currentPlayer,
    status: newStatus,
  );
}
```

Key decisions:
1. **Guard clause first** — if the game is already over or the cell is unavailable, return `this` unchanged.
2. **Ask the board** — `board.move(index, currentPlayer)` gives us the new board state; we do not replicate that logic here.
3. **Determine the new status** — check winner before draw, because a full board with a winner should be `xWins`/`oWins`, not `draw`.
4. **Switch turns only if still playing** — if the game just ended, `currentPlayer` stays as the player who made the winning move. This makes it easy to display "X wins!" without needing to remember who won separately.

### reset()

```dart
Game reset() => Game.start();
```

Simply delegates to `Game.start()`. Keeping it as a method (rather than just calling `Game.start()` directly in the UI) means future milestones can call `game.reset()` and get a fresh game without knowing the implementation.

---

## Step 6 — Write the Tests

Tests live in `test/game/`. We use the same copyright header as source files.

### `test/game/board_test.dart`

Create the file with this content:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game/board.dart';
import 'package:tictactoe/game/player.dart';

void main() {
  group('Board.empty()', () {
    test('all cells are null', () {
      final board = Board.empty();
      for (var i = 0; i < 9; i++) {
        expect(board[i], isNull);
      }
    });

    test('all moves are valid', () {
      final board = Board.empty();
      for (var i = 0; i < 9; i++) {
        expect(board.canMove(i), isTrue);
      }
    });

    test('out-of-range index is not a valid move', () {
      final board = Board.empty();
      expect(board.canMove(-1), isFalse);
      expect(board.canMove(9), isFalse);
    });

    test('has no winner', () => expect(Board.empty().winner, isNull));
    test('is not a draw', () => expect(Board.empty().isDraw, isFalse));
    test('is not terminal', () => expect(Board.empty().isTerminal, isFalse));
    test('emptyCells returns all 9 indices', () {
      expect(Board.empty().emptyCells, List.generate(9, (i) => i));
    });
  });

  group('Board.move()', () {
    test('places the player in the correct cell', () {
      final board = Board.empty().move(4, Player.x);
      expect(board[4], Player.x);
    });

    test('does not mutate other cells', () {
      final board = Board.empty().move(4, Player.x);
      for (var i = 0; i < 9; i++) {
        if (i != 4) expect(board[i], isNull);
      }
    });

    test('move on occupied cell returns same board', () {
      final board = Board.empty().move(4, Player.x);
      final same = board.move(4, Player.o);
      expect(same[4], Player.x);
    });

    test('move on out-of-range index returns same board', () {
      final board = Board.empty();
      expect(board.move(-1, Player.x), same(board));
      expect(board.move(9, Player.x), same(board));
    });

    test('canMove returns false for occupied cell', () {
      final board = Board.empty().move(0, Player.x);
      expect(board.canMove(0), isFalse);
    });

    test('emptyCells shrinks after each move', () {
      final board = Board.empty().move(0, Player.x).move(8, Player.o);
      expect(board.emptyCells, isNot(contains(0)));
      expect(board.emptyCells, isNot(contains(8)));
      expect(board.emptyCells.length, 7);
    });
  });

  group('Board winner detection', () {
    Board xWinsAt(List<int> indices) {
      var b = Board.empty();
      for (final i in indices) {
        b = b.move(i, Player.x);
      }
      return b;
    }

    test('row 0: X wins [0,1,2]', () => expect(xWinsAt([0, 1, 2]).winner, Player.x));
    test('row 1: X wins [3,4,5]', () => expect(xWinsAt([3, 4, 5]).winner, Player.x));
    test('row 2: X wins [6,7,8]', () => expect(xWinsAt([6, 7, 8]).winner, Player.x));
    test('col 0: X wins [0,3,6]', () => expect(xWinsAt([0, 3, 6]).winner, Player.x));
    test('col 1: X wins [1,4,7]', () => expect(xWinsAt([1, 4, 7]).winner, Player.x));
    test('col 2: X wins [2,5,8]', () => expect(xWinsAt([2, 5, 8]).winner, Player.x));
    test('diag: X wins [0,4,8]', () => expect(xWinsAt([0, 4, 8]).winner, Player.x));
    test('anti-diag: X wins [2,4,6]', () => expect(xWinsAt([2, 4, 6]).winner, Player.x));

    test('O can also win', () {
      var b = Board.empty()
          .move(0, Player.o)
          .move(1, Player.o)
          .move(2, Player.o);
      expect(b.winner, Player.o);
    });

    test('partial row is not a win', () {
      final b = Board.empty().move(0, Player.x).move(1, Player.x);
      expect(b.winner, isNull);
    });

    test('mixed row is not a win', () {
      final b = Board.empty()
          .move(0, Player.x)
          .move(1, Player.o)
          .move(2, Player.x);
      expect(b.winner, isNull);
    });
  });

  group('Board draw detection', () {
    // X O X
    // O O X
    // X X O  — no winner, all cells filled
    Board drawBoard() {
      return Board.empty()
          .move(0, Player.x)
          .move(1, Player.o)
          .move(2, Player.x)
          .move(3, Player.o)
          .move(4, Player.o)
          .move(5, Player.x)
          .move(6, Player.x)
          .move(7, Player.x)
          .move(8, Player.o);
    }

    test('full board with no winner is a draw', () {
      expect(drawBoard().isDraw, isTrue);
    });

    test('draw board is terminal', () {
      expect(drawBoard().isTerminal, isTrue);
    });

    test('partial board is not a draw', () {
      expect(Board.empty().isDraw, isFalse);
    });

    test('winning board is not a draw', () {
      final b = Board.empty().move(0, Player.x).move(1, Player.x).move(2, Player.x);
      expect(b.isDraw, isFalse);
    });
  });

  group('Board.isTerminal', () {
    test('true when there is a winner', () {
      final b = Board.empty().move(0, Player.x).move(1, Player.x).move(2, Player.x);
      expect(b.isTerminal, isTrue);
    });

    test('false while game is still in progress', () {
      final b = Board.empty().move(0, Player.x).move(4, Player.o);
      expect(b.isTerminal, isFalse);
    });
  });
}
```

### `test/game/game_test.dart`

Create the file with this content:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game/game.dart';
import 'package:tictactoe/game/game_status.dart';
import 'package:tictactoe/game/player.dart';

void main() {
  group('Game.start()', () {
    test('board is empty', () {
      final game = Game.start();
      for (var i = 0; i < 9; i++) {
        expect(game.board[i], isNull);
      }
    });

    test('X goes first', () => expect(Game.start().currentPlayer, Player.x));
    test('status is playing', () => expect(Game.start().status, GameStatus.playing));
    test('isOver is false', () => expect(Game.start().isOver, isFalse));
  });

  group('Game.move() — turn alternation', () {
    test('after X moves, current player is O', () {
      final game = Game.start().move(0);
      expect(game.currentPlayer, Player.o);
      expect(game.board[0], Player.x);
    });

    test('after X then O, current player is X again', () {
      final game = Game.start().move(0).move(1);
      expect(game.currentPlayer, Player.x);
      expect(game.board[1], Player.o);
    });

    test('move on occupied cell is a no-op', () {
      final before = Game.start().move(0);
      final after = before.move(0);
      expect(after.board[0], Player.x);
      expect(after.currentPlayer, Player.o);
      expect(identical(before, after), isTrue);
    });

    test('move on out-of-range index is a no-op', () {
      final game = Game.start();
      expect(identical(game.move(-1), game), isTrue);
      expect(identical(game.move(9), game), isTrue);
    });
  });

  group('Game.move() — X wins', () {
    // X: 0,1,2  O: 3,4
    Game xWinsRow() =>
        Game.start().move(0).move(3).move(1).move(4).move(2);

    test('status becomes xWins', () => expect(xWinsRow().status, GameStatus.xWins));
    test('isOver becomes true', () => expect(xWinsRow().isOver, isTrue));
    test('currentPlayer stays X after win', () => expect(xWinsRow().currentPlayer, Player.x));

    test('move after game over is a no-op', () {
      final won = xWinsRow();
      final still = won.move(5);
      expect(identical(won, still), isTrue);
    });
  });

  group('Game.move() — O wins', () {
    // X: 0,1,6  O: 3,4,5
    Game oWinsRow() =>
        Game.start().move(0).move(3).move(1).move(4).move(6).move(5);

    test('status becomes oWins', () => expect(oWinsRow().status, GameStatus.oWins));
    test('isOver becomes true', () => expect(oWinsRow().isOver, isTrue));
    test('currentPlayer stays O after win', () => expect(oWinsRow().currentPlayer, Player.o));
  });

  group('Game.move() — diagonal wins', () {
    test('X wins main diagonal [0,4,8]', () {
      final game = Game.start().move(0).move(1).move(4).move(2).move(8);
      expect(game.status, GameStatus.xWins);
    });

    test('X wins anti-diagonal [2,4,6]', () {
      final game = Game.start().move(2).move(0).move(4).move(1).move(6);
      expect(game.status, GameStatus.xWins);
    });
  });

  group('Game.move() — draw', () {
    // X O X
    // O O X
    // X X O — draw
    Game drawGame() => Game.start()
        .move(0).move(1)
        .move(2).move(3)
        .move(7).move(4)
        .move(5).move(8)
        .move(6);

    test('status becomes draw', () => expect(drawGame().status, GameStatus.draw));
    test('isOver becomes true', () => expect(drawGame().isOver, isTrue));
  });

  group('Game.reset()', () {
    test('returns a fresh game after win', () {
      final reset = Game.start().move(0).move(3).move(1).move(4).move(2).reset();
      expect(reset.status, GameStatus.playing);
      expect(reset.currentPlayer, Player.x);
      for (var i = 0; i < 9; i++) {
        expect(reset.board[i], isNull);
      }
    });

    test('returns a fresh game mid-play', () {
      final reset = Game.start().move(0).move(1).reset();
      expect(reset.board[0], isNull);
      expect(reset.currentPlayer, Player.x);
    });
  });
}
```

---

## Step 7 — Run the Quality Gates

```bash
flutter analyze
flutter test
```

Expected output for `flutter test`:

```
00:00 +0: loading test/game/board_test.dart
00:01 +N: All tests passed!
```

All tests must pass and `flutter analyze` must report zero issues before you commit.

---

## Step 8 — Commit

Stage only the files you created:

```bash
git add lib/game/player.dart
git add lib/game/game_status.dart
git add lib/game/board.dart
git add lib/game/game.dart
git add test/game/board_test.dart
git add test/game/game_test.dart
```

Then commit using the project's commit format:

```bash
git commit -m "feat(game): implement core board state and game logic"
```

---

## File Structure After This Milestone

```
lib/
  game/
    player.dart       — Player enum + opponent/label helpers
    game_status.dart  — GameStatus enum (playing/xWins/oWins/draw)
    board.dart        — Immutable 9-cell board, move, winner, draw detection
    game.dart         — Game coordinator (board + currentPlayer + status)
  main.dart           — unchanged Flutter scaffold

test/
  game/
    board_test.dart   — 26 tests covering Board
    game_test.dart    — 18 tests covering Game
  widget_test.dart    — unchanged scaffold test
```

---

## Common Mistakes to Avoid

| Mistake | Why it matters |
|---|---|
| Forgetting the copyright header | The project enforces it on every `.dart` file |
| Making `Board` or `Game` mutable (adding setters) | Breaks the immutability contract; tests check `identical()` |
| Checking `isDraw` before `winner` | A full board with a winner would be misreported as a draw |
| Switching `currentPlayer` even after a win | The UI in later milestones reads `currentPlayer` to show who won |
| Committing to `main` directly | Branch rule — everything goes to `milestone/01-game-logic` first |

---

## Key Dart Concepts Used

| Concept | Where used |
|---|---|
| `enum` | `Player`, `GameStatus` |
| `extension` | `PlayerX on Player` (adds `opponent` and `label`) |
| Named constructor (`Board._`) | Private constructor enforcing immutability |
| `factory` constructor | `Board.empty()`, `Game.start()` |
| `List.unmodifiable()` | Prevents mutation of `Board.cells` after construction |
| `List<Player?>.from(cells)` | Creates a mutable copy to modify before re-wrapping |
| Nullable types (`Player?`) | Empty cells hold `null` |
| `operator []` override | `board[4]` syntax |
| Collection-if in list literal | `emptyCells` getter |
| `identical()` | Tests check that no-op moves return the exact same instance |
