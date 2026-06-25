# Tic Tac Toe

A Flutter Tic Tac Toe game targeting Android and Web.

**Owner:** FullStackShack  
**Package:** com.fullstackshack.tictactoe  
**Flutter:** 3.41.4 | **Dart:** 3.11.1

## Getting Started

```bash
flutter pub get
flutter run -d chrome       # Web
flutter run -d <device-id>  # Android
```

## Project Structure

```
lib/
  main.dart               # App entry point
  game/
    player.dart           # Player enum (x, o) + opponent/label
    board.dart            # Immutable Board — move, win, draw detection
    game_status.dart      # GameStatus enum
    game.dart             # Immutable Game state machine
test/
  widget_test.dart        # Widget smoke test
  game/
    board_test.dart       # 30 Board unit tests
    game_test.dart        # 22 Game unit tests
docs/                     # Milestone documentation
CLAUDE.md                 # AI session guide and templates
BUILD_LOG.md              # Command history with exact output
CHANGELOG.md              # Notable changes per milestone
```

## Milestones

| # | Name            | Status                    |
|---|-----------------|---------------------------|
| 00 | Project Setup  | Complete                  |
| 01 | Game Logic     | Complete (merge pending)  |
| 02 | Basic UI       | Pending                   |
| 03 | Win Detection  | Pending                   |
| 04 | AI Player      | Pending                   |
| 05 | Polish         | Pending                   |

See [BUILD_LOG.md](BUILD_LOG.md) for full session history.
