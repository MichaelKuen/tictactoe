# Tutorial — Milestone 02: Basic UI

**Branch:** `milestone/02-basic-ui`  
**Goal:** Wire the game logic from Milestone 01 to a visible Flutter UI — a 3×3 grid, X/O marks, tap to play, and a reset button.

By the end of this tutorial you will have:
- 3 new UI widget files under `lib/ui/`
- A rewritten `lib/main.dart`
- 5 widget tests under `test/ui/`
- All 57 tests passing with zero analyzer issues

---

## Before You Start

Make sure Milestone 01 is merged to `main`. You should already have:

```
lib/
  game/
    player.dart
    game_status.dart
    board.dart
    game.dart
  main.dart        ← still the Flutter counter demo

test/
  game/
    board_test.dart
    game_test.dart
  widget_test.dart ← still the counter smoke test
```

Check your starting point:

```bash
flutter analyze
flutter test
```

Both must exit clean before you touch anything.

---

## How the UI Layer Fits In (Mental Model)

The game layer from Milestone 01 is completely pure Dart — no Flutter, no widgets, no `setState`. The UI layer sits on top and has one job: **display the current `Game` state and translate taps into `game.move(index)` calls**.

```
User taps cell 4
       │
       ▼
  GameScreen._onCellTap(4)
       │
       ▼
  _game = _game.move(4)   ← new immutable Game value
       │
       ▼
  setState(() { ... })    ← Flutter rebuilds the widget tree
       │
       ▼
  BoardWidget redraws 9 cells from the new board
```

The `Game` object itself never changes — `move()` always returns a brand-new instance. Flutter's `setState` is what triggers the visual rebuild.

---

## Design Philosophy

### Separate concerns strictly

The widget files know nothing about win detection, whose turn it is in terms of game rules, or what a `Board` is internally. `GameScreen` holds the `Game` and exposes only what each child needs:

- `BoardWidget` gets a `Board` and a tap callback.
- `CellWidget` gets a `Player?` (the cell's value) and a tap callback.

This means you can test `BoardWidget` without a real `Game`, and you can test `CellWidget` with any `Player?` value.

### State lives in exactly one place

`GameScreen` owns the single `_game` field. Nothing else holds state. When a tap arrives, `GameScreen` computes the new game and calls `setState`. Every descendant widget is stateless and derives its appearance entirely from what it is passed.

### Immutable UI inputs, stateless widgets

Because `Game` and `Board` are immutable, Flutter can safely compare old and new widget trees. Passing a new `Board` to `BoardWidget` is enough for Flutter to know it needs to rebuild.

---

## Step 1 — Create the `lib/ui/` folder

Create the directory `lib/ui/`. You can do this from your IDE or terminal:

```
lib/
  game/        ← already exists
  ui/          ← create this
  main.dart
```

Also create the test directory:

```
test/
  game/        ← already exists
  ui/          ← create this
  widget_test.dart
```

---

## Step 2 — `lib/ui/cell_widget.dart`

**What it does:** Renders a single cell — a rounded bordered box that shows X, O, or nothing. Handles the tap gesture.

**Create the file** `lib/ui/cell_widget.dart`:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/player.dart';

class CellWidget extends StatelessWidget {
  final Player? player;
  final VoidCallback? onTap;

  const CellWidget({super.key, required this.player, this.onTap});

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
          border: Border.all(color: theme.colorScheme.outline),
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

**Explanation — section by section:**

### The fields

```dart
final Player? player;
final VoidCallback? onTap;
```

- `player` is nullable — `null` means the cell is empty.
- `onTap` is also nullable — `GameScreen` passes `null` here when the game is over, disabling all taps cleanly without the cell needing to know why.

### Colour by player

```dart
final color = player == Player.x
    ? theme.colorScheme.primary
    : theme.colorScheme.secondary;
```

X gets the primary theme colour, O gets the secondary. We pull these from the `ThemeData` so the entire app can be re-themed by changing a single seed colour in `main.dart`. This line runs even when `player == null`, but the result is only used when `player != null` (inside the `Text`), so it's harmless.

### Disabling tap on occupied cells

```dart
onTap: player == null ? onTap : null,
```

`GestureDetector` with `onTap: null` is completely inert — it registers no gesture recogniser and the tap falls through. This is the idiomatic Flutter way to conditionally disable a tap without wrapping in an `AbsorbPointer` or `IgnorePointer`. The `Game.move()` already guards against occupied cells, but disabling the tap here prevents unnecessary `setState` calls and gives instant visual feedback (no ink splash on filled cells).

### The visual container

```dart
Container(
  margin: const EdgeInsets.all(4),
  decoration: BoxDecoration(
    border: Border.all(color: theme.colorScheme.outline),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Center(
    child: player != null ? Text(...) : null,
  ),
),
```

- `margin: EdgeInsets.all(4)` creates the visible gaps between cells in the grid.
- `Border.all(color: theme.colorScheme.outline)` draws the cell boundary using the theme's outline colour.
- `borderRadius: BorderRadius.circular(8)` rounds the corners.
- When `player == null` the `child` of `Center` is `null` — Flutter's `Center` accepts a null child and renders nothing, keeping the cell visually empty.

### Why `StatelessWidget`?

`CellWidget` has no internal state — it is a pure function of `player` and `onTap`. Every time the board changes, `GameScreen` rebuilds and passes fresh values down. Stateless widgets are cheaper to rebuild and easier to test.

---

## Step 3 — `lib/ui/board_widget.dart`

**What it does:** Lays out 9 `CellWidget`s in a 3×3 grid and forwards the tap index up to the parent.

**Create the file** `lib/ui/board_widget.dart`:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/board.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final void Function(int index)? onCellTap;

  const BoardWidget({super.key, required this.board, this.onCellTap});

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
          onTap: onCellTap != null ? () => onCellTap!(index) : null,
        ),
      ),
    );
  }
}
```

**Explanation — section by section:**

### `AspectRatio(aspectRatio: 1)`

```dart
return AspectRatio(
  aspectRatio: 1,
  child: GridView.builder(...),
);
```

`AspectRatio` forces its child to maintain a given width-to-height ratio. A ratio of `1` means the widget is always a perfect square. Without this, `GridView` would try to fill all available vertical space, making the grid rectangular.

### `GridView.builder` vs `GridView.count`

`GridView.builder` is lazily evaluated — it only builds the cells that are on screen. For a fixed 9-cell board this makes no difference, but it is the idiomatic choice when the item count comes from data rather than a literal list.

### `NeverScrollableScrollPhysics`

```dart
physics: const NeverScrollableScrollPhysics(),
```

`GridView` is scrollable by default. We disable scrolling here because the board is always exactly 9 cells — there is nothing to scroll. This also prevents scroll conflicts if the `BoardWidget` is ever placed inside a larger scrollable layout.

### `SliverGridDelegateWithFixedCrossAxisCount`

```dart
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
),
```

`crossAxisCount: 3` means 3 columns. Each cell gets an equal share of the available width (one third) and the same height (since `AspectRatio(1)` makes the grid square, each cell is also a square).

### Cell keys and the tap callback

```dart
itemBuilder: (_, index) => CellWidget(
  key: ValueKey('cell_$index'),
  player: board[index],
  onTap: onCellTap != null ? () => onCellTap!(index) : null,
),
```

- `key: ValueKey('cell_$index')` gives each cell a stable identity. This allows widget tests to find a specific cell with `find.byKey(ValueKey('cell_0'))` — far more reliable than `find.byType(GestureDetector).first`, which could match any gesture detector in the tree.
- `onCellTap != null ? () => onCellTap!(index) : null` — if the parent did not provide a callback (game is over), we pass `null` to `CellWidget`, which then passes `null` to its `GestureDetector`, disabling all taps for free.

---

## Step 4 — `lib/ui/game_screen.dart`

**What it does:** Owns the `Game` state, translates taps into moves, and composes everything into a screen.

**Create the file** `lib/ui/game_screen.dart`:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/game.dart';
import '../game/game_status.dart';
import '../game/player.dart';
import 'board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Game _game = Game.start();

  void _onCellTap(int index) {
    setState(() {
      _game = _game.move(index);
    });
  }

  void _reset() {
    setState(() {
      _game = _game.reset();
    });
  }

  String get _statusText {
    switch (_game.status) {
      case GameStatus.playing:
        return "${_game.currentPlayer.label}'s turn";
      case GameStatus.xWins:
        return 'X wins!';
      case GameStatus.oWins:
        return 'O wins!';
      case GameStatus.draw:
        return 'Draw!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _statusText,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
                    child: BoardWidget(
                      board: _game.board,
                      onCellTap: _game.isOver ? null : _onCellTap,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _reset,
                child: const Text('New Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Explanation — section by section:**

### `StatefulWidget` vs `StatelessWidget`

`GameScreen` is a `StatefulWidget` because it needs to remember the current `Game` between frame builds. The `_GameScreenState` class holds the mutable `_game` field. All other widgets in this milestone are stateless.

### The `_game` field

```dart
Game _game = Game.start();
```

This is the single source of truth for the entire screen. Every widget below `GameScreen` derives its appearance from this value. Initialising with `Game.start()` means the screen opens with an empty board and X to play.

### `_onCellTap`

```dart
void _onCellTap(int index) {
  setState(() {
    _game = _game.move(index);
  });
}
```

`setState` tells Flutter to rebuild the widget tree after `_game` changes. Notice we replace `_game` entirely with the return value of `move()` — we never mutate the existing instance. `Game.move()` handles all the guards (occupied cell, game already over), so this method does not need any `if` statements.

### `_statusText` — an exhaustive switch

```dart
String get _statusText {
  switch (_game.status) {
    case GameStatus.playing:
      return "${_game.currentPlayer.label}'s turn";
    case GameStatus.xWins:
      return 'X wins!';
    case GameStatus.oWins:
      return 'O wins!';
    case GameStatus.draw:
      return 'Draw!';
  }
}
```

A Dart `switch` on an enum is exhaustive — the compiler will error if you miss a case. This means adding a new `GameStatus` value in the future will force you to handle it here immediately. Contrast with a chain of `if/else if` where a missed case silently falls through.

We import `player.dart` directly here (not just through `game.dart`) because the `label` getter lives in the `PlayerX` extension defined in that file. In Dart, extension methods are only in scope when the file that defines them is explicitly imported.

### Layout: `SafeArea`, `Flexible`, `ConstrainedBox`

```dart
body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_statusText, ...),
        const SizedBox(height: 16),
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
              child: BoardWidget(...),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(...),
      ],
    ),
  ),
),
```

Three layout decisions worth understanding:

**`SafeArea`** insets the content away from device notches, status bars, and home indicators. Without it, content can be clipped on phones with a notch or gesture bar.

**`Flexible` around the board**: In a `Column`, non-flex children (the `Text`, `SizedBox`s, and `FilledButton`) take their natural size. The remaining space is shared among `Flexible`/`Expanded` children. Wrapping the board in `Flexible` means it fills whatever vertical space is left after the other elements have taken their share — rather than trying to be a fixed 360px tall and potentially overflowing on small screens or in test viewports.

**`ConstrainedBox(maxWidth: 360, maxHeight: 360)`** prevents the board from becoming enormous on large screens (tablets, desktops). The `AspectRatio(1)` above it ensures the board stays square within whatever space `Flexible` grants.

### Disabling taps when the game is over

```dart
onCellTap: _game.isOver ? null : _onCellTap,
```

When the game is over, we pass `null` instead of the callback. This propagates all the way down: `BoardWidget` passes `null` to each `CellWidget`, which passes `null` to each `GestureDetector`. No cell can be tapped after the game ends, with zero conditional logic in the child widgets.

---

## Step 5 — Rewrite `lib/main.dart`

Replace the entire counter demo with:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'ui/game_screen.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
```

**Explanation:**

- `useMaterial3: true` opts in to Material 3 styling (rounded components, dynamic colour, updated typography). This is the modern default for new Flutter apps.
- `ColorScheme.fromSeed(seedColor: Colors.indigo)` generates a full harmonious colour palette from a single seed. Change the seed colour here to re-theme the entire app.
- `home: const GameScreen()` replaces the old counter demo with our game screen.

---

## Step 6 — Write the Widget Tests

### Update `test/widget_test.dart`

Replace the counter smoke test:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/main.dart';

void main() {
  testWidgets('app smoke test — renders without error', (tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    expect(find.text('Tic Tac Toe'), findsOneWidget);
  });
}
```

### Create `test/ui/game_screen_test.dart`

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/ui/game_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

Finder _cell(int index) => find.byKey(ValueKey('cell_$index'));

void main() {
  testWidgets('shows X turn initially', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    expect(find.text("X's turn"), findsOneWidget);
  });

  testWidgets('tapping a cell places X', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    await tester.tap(_cell(0));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    expect(find.text("O's turn"), findsOneWidget);
  });

  testWidgets('tapping an occupied cell has no effect', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    await tester.tap(_cell(0));
    await tester.pump();
    await tester.tap(_cell(0));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    expect(find.text("O's turn"), findsOneWidget);
  });

  testWidgets('New Game button resets the board', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    await tester.tap(_cell(0));
    await tester.pump();
    await tester.tap(find.text('New Game'));
    await tester.pump();
    expect(find.text('X'), findsNothing);
    expect(find.text("X's turn"), findsOneWidget);
  });

  testWidgets('X wins shows win message', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    // X: 0, O: 3, X: 1, O: 4, X: 2 — top row win for X
    await tester.tap(_cell(0)); await tester.pump();
    await tester.tap(_cell(3)); await tester.pump();
    await tester.tap(_cell(1)); await tester.pump();
    await tester.tap(_cell(4)); await tester.pump();
    await tester.tap(_cell(2)); await tester.pump();
    expect(find.text('X wins!'), findsOneWidget);
  });
}
```

**Explanation — key points:**

### `_wrap` helper

```dart
Widget _wrap(Widget child) => MaterialApp(home: child);
```

`GameScreen` uses `Theme.of(context)` internally, which requires a `MaterialApp` ancestor. This one-liner provides that ancestor so tests can render `GameScreen` in isolation without importing the full `TicTacToeApp`.

### `_cell(index)` helper

```dart
Finder _cell(int index) => find.byKey(ValueKey('cell_$index'));
```

Using `find.byKey(ValueKey('cell_0'))` is far more reliable than `find.byType(GestureDetector).first`. The widget tree contains many `GestureDetector`s (from `MaterialApp`, `Scaffold`, etc.) and `.first` could match any of them. The `ValueKey` targets exactly the cell we want.

### `await tester.pump()`

After every `tester.tap(...)`, you must call `tester.pump()` to let Flutter process the event, run `setState`, and rebuild the widget tree. Without it, the next `expect` would see the old state.

### Testing the "no-op" tap

```dart
await tester.tap(_cell(0)); // places X
await tester.pump();
await tester.tap(_cell(0)); // second tap — should be ignored
await tester.pump();
expect(find.text('X'), findsOneWidget); // still exactly 1 X
expect(find.text("O's turn"), findsOneWidget); // still O's turn
```

This test confirms that:
1. The `GestureDetector`'s `onTap` is `null` on an occupied cell (so the tap does nothing in the UI layer).
2. Even if it were not `null`, `Game.move()` would be a no-op on an occupied cell (defence in depth).

---

## Step 7 — Run the Quality Gates

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
+57: All tests passed!
```

If `flutter analyze` flags missing imports, the most common cause is using an extension method (like `.label` on `Player`) without importing the file where the extension is defined. In `game_screen.dart`, you need `import '../game/player.dart'` even though `game.dart` imports it — Dart does not re-export transitive imports.

---

## Step 8 — Commit

Stage only the files you created or changed:

```bash
git add lib/main.dart
git add lib/ui/game_screen.dart
git add lib/ui/board_widget.dart
git add lib/ui/cell_widget.dart
git add test/widget_test.dart
git add test/ui/game_screen_test.dart
```

Then commit:

```bash
git commit -m "feat(ui): implement basic game UI — grid, X/O rendering, tap to play"
```

---

## File Structure After This Milestone

```
lib/
  game/
    player.dart         — Player enum + helpers (unchanged)
    game_status.dart    — GameStatus enum (unchanged)
    board.dart          — Board logic (unchanged)
    game.dart           — Game state machine (unchanged)
  ui/
    game_screen.dart    — StatefulWidget: owns Game state
    board_widget.dart   — 3×3 GridView with keyed cells
    cell_widget.dart    — Single cell: GestureDetector + themed text
  main.dart             — TicTacToeApp (Material 3, indigo theme)

test/
  game/
    board_test.dart     — 30 Board tests (unchanged)
    game_test.dart      — 22 Game tests (unchanged)
  ui/
    game_screen_test.dart — 5 widget tests
  widget_test.dart      — app smoke test (updated)
```

---

## Common Mistakes to Avoid

| Mistake | Why it matters |
|---|---|
| Forgetting to import `player.dart` in `game_screen.dart` | The `label` extension method is defined there; importing only `game.dart` is not enough |
| Using `find.byType(GestureDetector).first` in tests | Matches unrelated gesture detectors in `MaterialApp`/`Scaffold`; use `ValueKey` instead |
| Skipping `await tester.pump()` after a tap | The widget tree won't rebuild; your `expect` will see stale state |
| Making `BoardWidget` or `CellWidget` stateful | State belongs in `GameScreen`; children should be pure functions of their inputs |
| Putting `AspectRatio` without `Flexible` in a `Column` | The board tries to be as wide as its parent, which overflows on small screens |
| Hardcoding colours instead of using `Theme.of(context)` | The app can't be re-themed without touching widget code |
| Committing directly to `main` | Branch rule — everything goes to `milestone/02-basic-ui` first |

---

## Key Flutter / Dart Concepts Used

| Concept | Where used |
|---|---|
| `StatefulWidget` / `State` | `GameScreen` — holds `_game`, calls `setState` |
| `StatelessWidget` | `BoardWidget`, `CellWidget`, `TicTacToeApp` |
| `setState` | `_onCellTap`, `_reset` — triggers widget rebuild |
| `GestureDetector` with nullable `onTap` | `CellWidget` — disables tap when `onTap` is null |
| `GridView.builder` | `BoardWidget` — 3-column grid of cells |
| `AspectRatio` | `BoardWidget` (square grid), `GameScreen` (square block in column) |
| `Flexible` | `GameScreen` — board yields space to other children |
| `ConstrainedBox` | `GameScreen` — caps board size on large screens |
| `SafeArea` | `GameScreen` — avoids notches and system UI overlays |
| `ValueKey` | `BoardWidget` — stable cell identity for widget tests |
| `Theme.of(context)` | `CellWidget`, `GameScreen` — pulls colours and text styles |
| `ColorScheme.fromSeed` | `main.dart` — generates a full palette from one colour |
| Exhaustive `switch` on enum | `_statusText` — compiler errors if a case is missed |
| `find.byKey` in widget tests | `game_screen_test.dart` — reliable cell targeting |
