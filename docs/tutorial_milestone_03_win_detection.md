# Tutorial — Milestone 03: Win Detection UI

**Branch:** `milestone/03-win-detection`  
**Goal:** Surface the winning line visually — highlight the 3 cells that formed a winning combination so the player can see exactly how the game was decided.

By the end of this tutorial you will have:
- A new `winningLine` getter on `Board`
- A `highlighted` parameter on `CellWidget` with themed styling
- `BoardWidget` and `GameScreen` wired to pass the winning line down
- 7 new tests (5 unit, 2 widget), bringing the total to 64

---

## Before You Start

Make sure Milestone 02 is merged to `main`. You should already have:

```
lib/
  game/
    player.dart
    game_status.dart
    board.dart        ← we will add winningLine here
    game.dart
  ui/
    game_screen.dart  ← we will add one line here
    board_widget.dart ← we will add winningLine param here
    cell_widget.dart  ← we will add highlighted param here
  main.dart

test/
  game/
    board_test.dart   ← we will add 5 tests here
    game_test.dart
  ui/
    game_screen_test.dart ← we will add 2 tests here
  widget_test.dart
```

Check your starting point:

```bash
flutter analyze
flutter test
```

Both must exit clean (57 tests passing) before you begin.

---

## What This Milestone Does (Mental Model)

After Milestone 02, the game already knows who won — `GameStatus.xWins`, `GameStatus.oWins`, and the `board.winner` getter are all in place. What was missing is *which cells* formed the winning line.

```
X | O | X
---------
. | X | O
---------
. | . | X    ← X wins the main diagonal [0, 4, 8]
```

The winning cells need to be visually distinct so the result is immediately clear. The data flow is:

```
Board.winningLine → [0, 4, 8]
       │
       ▼
BoardWidget(winningLine: [0, 4, 8])
       │
       for each cell index 0..8:
       ▼
CellWidget(highlighted: winningLine.contains(index))
       │
       ▼
Container with primaryContainer background + primary border
```

Everything below `GameScreen` is stateless — they just render what they receive. `Board` computes the winning line from the same data it already uses for `winner`.

---

## Design Philosophy

### Derive from existing data, don't duplicate it

`Board` already loops over `_winLines` to find `winner`. `winningLine` does the exact same loop and returns the matching line instead of the player. There is no new data structure, no extra state, and no risk of the winning line disagreeing with the winning player.

### Push visual decisions up, push data decisions down

`CellWidget` does not know what a "winning line" is. It only knows `highlighted: true` or `highlighted: false`. The decision of *whether* a cell is highlighted belongs to `BoardWidget`, which receives `winningLine` from `GameScreen`, which gets it from `Board`. Each layer does exactly one thing.

### Theme colours, not hardcoded values

The highlight uses `theme.colorScheme.primaryContainer` (background) and `theme.colorScheme.primary` (border). If you change the seed colour in `main.dart` from `Colors.indigo` to any other colour, the highlight re-themes automatically — zero extra work.

---

## Step 1 — Add `winningLine` to `Board`

Open `lib/game/board.dart`. You will add one new getter immediately after the existing `winner` getter.

**Current `winner` getter (for reference):**

```dart
Player? get winner {
  for (final line in _winLines) {
    final a = cells[line[0]];
    if (a != null && a == cells[line[1]] && a == cells[line[2]]) return a;
  }
  return null;
}
```

**Add `winningLine` directly below it:**

```dart
List<int>? get winningLine {
  for (final line in _winLines) {
    final a = cells[line[0]];
    if (a != null && a == cells[line[1]] && a == cells[line[2]]) return line;
  }
  return null;
}
```

**The full updated `board.dart`:**

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

  List<int>? get winningLine {
    for (final line in _winLines) {
      final a = cells[line[0]];
      if (a != null && a == cells[line[1]] && a == cells[line[2]]) return line;
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

**Explanation:**

### Return type `List<int>?`

```dart
List<int>? get winningLine {
```

The `?` makes the return type nullable. When there is no winner (still playing, or a draw), the getter returns `null`. This is the correct signal to pass downstream: `null` means "no cells to highlight."

### Why not just call `winner` then look up the line?

You might think: "find the winner, then loop again to find which line they won." That works but loops twice. Since `winningLine` already returns the player implicitly (both cells in the winning line belong to the same player), computing both `winner` and `winningLine` from the same single loop is cleaner. If you need both, call `winningLine` to get the line and `cells[line[0]]` to get the winning player.

### Why is `winningLine` not on `Game` instead of `Board`?

`Board` owns the cell data and the win-line definitions. `Game` is a coordinator that delegates to `Board`. Keeping `winningLine` on `Board` keeps the data next to the logic that produces it, and `GameScreen` can reach it as `_game.board.winningLine`.

---

## Step 2 — Add `highlighted` to `CellWidget`

Open `lib/ui/cell_widget.dart` and update it:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/player.dart';

class CellWidget extends StatelessWidget {
  final Player? player;
  final VoidCallback? onTap;
  final bool highlighted;

  const CellWidget({
    super.key,
    required this.player,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = player == Player.x
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return GestureDetector(
      onTap: player == null ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: highlighted ? theme.colorScheme.primaryContainer : null,
          border: Border.all(
            color: highlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: highlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: player != null
              ? Text(
                  player!.label,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
```

**Explanation — what changed:**

### The new field and its default

```dart
final bool highlighted;

const CellWidget({
  super.key,
  required this.player,
  this.onTap,
  this.highlighted = false,
});
```

`highlighted` defaults to `false`. This means every existing caller that does not pass `highlighted` continues to work unchanged — the cell just renders normally. Default parameters are the idiomatic Dart way to add optional behaviour without breaking call sites.

### Conditional background colour

```dart
color: highlighted ? theme.colorScheme.primaryContainer : null,
```

When `null`, `Container` has no background — it is transparent. When `highlighted`, it fills with `primaryContainer`, a soft tinted version of the primary colour chosen specifically by Material 3 for container backgrounds. Using `null` rather than `Colors.transparent` is important: `null` lets the parent's background show through properly, whereas `Colors.transparent` can interfere with certain rendering modes.

### Conditional border style

```dart
border: Border.all(
  color: highlighted
      ? theme.colorScheme.primary
      : theme.colorScheme.outline,
  width: highlighted ? 2 : 1,
),
```

Highlighted cells get a thicker (`width: 2`) border in the primary colour, making the winning line stand out clearly against the normal `outline`-coloured borders of the other cells. The combination of background fill + thicker border creates a distinct visual without needing a completely different widget.

---

## Step 3 — Add `winningLine` to `BoardWidget`

Open `lib/ui/board_widget.dart` and update it:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/board.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final void Function(int index)? onCellTap;
  final List<int>? winningLine;

  const BoardWidget({
    super.key,
    required this.board,
    this.onCellTap,
    this.winningLine,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (_, index) => CellWidget(
          key: ValueKey('cell_$index'),
          player: board[index],
          highlighted: winningLine?.contains(index) ?? false,
          onTap: onCellTap != null ? () => onCellTap!(index) : null,
        ),
      ),
    );
  }
}
```

**Explanation — what changed:**

### The new field

```dart
final List<int>? winningLine;
```

Nullable because during normal play (and on a draw) there is no winning line. Defaulting to `null` in the constructor means every existing `BoardWidget(board: ...)` call still compiles without modification.

### Passing `highlighted` to each cell

```dart
highlighted: winningLine?.contains(index) ?? false,
```

This single expression does three things:
1. `winningLine?` — if `winningLine` is `null`, short-circuit and produce `null`
2. `.contains(index)` — check whether this cell's index is in the winning line
3. `?? false` — if the whole left side is `null` (no winning line), default to `false`

The result is `true` for exactly the 3 winning cells, and `false` for everything else — including when the game is still in progress. This is the idiomatic Dart null-aware pattern for "do something with a nullable value, fall back to a default."

---

## Step 4 — Wire `winningLine` in `GameScreen`

Open `lib/ui/game_screen.dart`. Find the `BoardWidget(...)` call inside `build` and add one line:

**Before:**

```dart
child: BoardWidget(
  board: _game.board,
  onCellTap: _game.isOver ? null : _onCellTap,
),
```

**After:**

```dart
child: BoardWidget(
  board: _game.board,
  winningLine: _game.board.winningLine,
  onCellTap: _game.isOver ? null : _onCellTap,
),
```

**Explanation:**

`_game.board.winningLine` returns `null` while the game is still going (or on a draw), and returns a `List<int>` of 3 indices after a win. `BoardWidget` and `CellWidget` handle both cases correctly — nothing else in `GameScreen` needs to change.

---

## Step 5 — Write the Tests

### New unit tests in `test/game/board_test.dart`

Add a new group at the end of the file, before the closing `}`:

```dart
group('Board.winningLine', () {
  test('null on empty board', () {
    expect(Board.empty().winningLine, isNull);
  });

  test('null mid-game with no winner', () {
    final b = Board.empty().move(0, Player.x).move(4, Player.o);
    expect(b.winningLine, isNull);
  });

  test('returns [0,1,2] when top row wins', () {
    final b = Board.empty()
        .move(0, Player.x)
        .move(1, Player.x)
        .move(2, Player.x);
    expect(b.winningLine, equals([0, 1, 2]));
  });

  test('returns [0,4,8] for main diagonal', () {
    final b = Board.empty()
        .move(0, Player.x)
        .move(4, Player.x)
        .move(8, Player.x);
    expect(b.winningLine, equals([0, 4, 8]));
  });

  test('null on a draw board', () {
    final b = Board.empty()
        .move(0, Player.x).move(1, Player.o).move(2, Player.x)
        .move(3, Player.o).move(4, Player.o).move(5, Player.x)
        .move(6, Player.x).move(7, Player.x).move(8, Player.o);
    expect(b.winningLine, isNull);
  });
});
```

**Explanation:**

- **`null` on empty / mid-game** — confirms no false positives while the game is still being played.
- **Exact line returned** — `equals([0, 1, 2])` checks the actual indices, not just that *something* is returned. This would catch a bug where the wrong line is returned.
- **`null` on draw** — a full board with no winner must not return a line. This is the most common source of false positives if the logic checks "all cells filled" before checking for a winner.

### New widget tests in `test/ui/game_screen_test.dart`

Add these two tests at the end of `main()`:

```dart
testWidgets('winning cells are highlighted after X wins', (tester) async {
  await tester.pumpWidget(_wrap(const GameScreen()));
  // X: 0, O: 3, X: 1, O: 4, X: 2 — top row win for X
  await tester.tap(_cell(0)); await tester.pump();
  await tester.tap(_cell(3)); await tester.pump();
  await tester.tap(_cell(1)); await tester.pump();
  await tester.tap(_cell(4)); await tester.pump();
  await tester.tap(_cell(2)); await tester.pump();

  // Winning cells 0,1,2 should have a highlight background
  for (final index in [0, 1, 2]) {
    final container = tester.widget<Container>(
      find.descendant(of: _cell(index), matching: find.byType(Container)),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNotNull,
        reason: 'cell $index should have a highlight background');
  }

  // Non-winning cells should not be highlighted
  for (final index in [3, 4]) {
    final container = tester.widget<Container>(
      find.descendant(of: _cell(index), matching: find.byType(Container)),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNull,
        reason: 'cell $index should not be highlighted');
  }
});

testWidgets('no cells are highlighted mid-game', (tester) async {
  await tester.pumpWidget(_wrap(const GameScreen()));
  await tester.tap(_cell(0));
  await tester.pump();

  final container = tester.widget<Container>(
    find.descendant(of: _cell(0), matching: find.byType(Container)),
  );
  final decoration = container.decoration as BoxDecoration;
  expect(decoration.color, isNull);
});
```

**Explanation — key technique:**

### Inspecting widget properties in tests

```dart
final container = tester.widget<Container>(
  find.descendant(of: _cell(index), matching: find.byType(Container)),
);
final decoration = container.decoration as BoxDecoration;
expect(decoration.color, isNotNull);
```

`tester.widget<T>(finder)` retrieves the actual widget instance from the tree so you can inspect its properties directly. We use `find.descendant` to scope the search to cells found by `ValueKey` — this avoids accidentally matching the wrong `Container` elsewhere in the tree.

The `as BoxDecoration` cast is safe here because we always assign a `BoxDecoration` in `CellWidget`. Casting without checking is normally risky, but since we control the widget, we know the type at this point.

`decoration.color` is `null` when not highlighted and a non-null `Color` when highlighted. Checking `isNotNull` / `isNull` rather than comparing the exact colour makes the test robust — it will still pass if you change the highlight colour in the future.

---

## Step 6 — Run the Quality Gates

```bash
flutter analyze
flutter test
```

Expected output for `flutter analyze`:

```
No issues found!
```

Expected output for `flutter test`:

```
+64: All tests passed!
```

Breakdown:
- 35 `board_test.dart` tests (30 existing + 5 new `winningLine` tests)
- 22 `game_test.dart` tests (unchanged)
- 7 `game_screen_test.dart` tests (5 existing + 2 new highlighting tests)
- 1 `widget_test.dart` smoke test (unchanged)

---

## Step 7 — Commit

Stage only the changed files:

```bash
git add lib/game/board.dart
git add lib/ui/cell_widget.dart
git add lib/ui/board_widget.dart
git add lib/ui/game_screen.dart
git add test/game/board_test.dart
git add test/ui/game_screen_test.dart
```

Then commit:

```bash
git commit -m "feat(ui): highlight winning cells on game over"
```

---

## File Structure After This Milestone

No new files — this milestone is entirely about extending existing ones:

```
lib/
  game/
    board.dart        — + winningLine getter
    (others unchanged)
  ui/
    cell_widget.dart  — + highlighted param
    board_widget.dart — + winningLine param
    game_screen.dart  — + passes board.winningLine to BoardWidget
    (main.dart unchanged)

test/
  game/
    board_test.dart   — + 5 winningLine tests
  ui/
    game_screen_test.dart — + 2 highlighting tests
  (others unchanged)
```

---

## Common Mistakes to Avoid

| Mistake | Why it matters |
|---|---|
| Checking `isDraw` before `winner` in `winningLine` | A full board with a winner would return `null` — same bug risk as in `winner` itself |
| Using `Colors.transparent` instead of `null` for no highlight | Can interfere with parent background rendering; `null` means "no colour" at the decoration level |
| Hardcoding `Colors.indigo` in `CellWidget` | Breaks re-theming; always pull colours from `Theme.of(context).colorScheme` |
| Forgetting `?? false` in `winningLine?.contains(index) ?? false` | Without the fallback, `highlighted` would be `bool?` (nullable), which `CellWidget` does not accept |
| Testing `decoration.color == theme.colorScheme.primaryContainer` | This is fragile — if you change the highlight colour the test breaks. `isNotNull` is sufficient |

---

## Key Dart / Flutter Concepts Used

| Concept | Where used |
|---|---|
| Nullable return type (`List<int>?`) | `Board.winningLine` — null means no winning line |
| Default parameter value (`highlighted = false`) | `CellWidget` — backward-compatible optional param |
| Null-aware call (`winningLine?.contains(index)`) | `BoardWidget` — safe call on nullable list |
| Null-coalescing operator (`?? false`) | `BoardWidget` — fallback when winningLine is null |
| `tester.widget<T>(finder)` | Widget tests — inspect actual widget properties |
| `find.descendant(of:, matching:)` | Widget tests — scope finder to a subtree |
| `as BoxDecoration` cast | Widget tests — access typed decoration properties |
| `theme.colorScheme.primaryContainer` | `CellWidget` — Material 3 container colour token |
