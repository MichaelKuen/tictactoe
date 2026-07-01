# Tic Tac Toe

A Flutter Tic Tac Toe game targeting Android and Web.

**Owner:** FullStackShack
**Package:** com.fullstackshack.tictactoe
**Flutter:** 3.41.4 | **Dart:** 3.11.1

---

## Getting Started

```bash
flutter pub get
flutter run -d chrome       # Web
flutter run -d <device-id>  # Android
```

---

## Project Structure

```
lib/
  main.dart               # App entry point (async — initialises AdMob before runApp)
  ads/
    ad_manager.dart       # AdManager singleton — banner, interstitial, rewarded ads
  game/
    player.dart           # Player enum (x, o) + opponent/label
    board.dart            # Immutable Board — move, win, draw detection
    game_status.dart      # GameStatus enum
    game.dart             # Immutable Game state machine
    ai.dart               # AiPlayer.bestMove() — minimax algorithm
  ui/
    game_screen.dart      # Main screen — layout, ad integration, hint flow
    board_widget.dart     # 3×3 GridView
    cell_widget.dart      # Individual cell — X/O, win highlight, hint highlight
test/
  widget_test.dart        # App smoke test
  game/
    board_test.dart       # 30 Board unit tests
    game_test.dart        # 22 Game unit tests
    ai_test.dart          # AI test suite (never-loses exhaustive)
  ui/
    game_screen_test.dart # Widget tests for game flow and ad interactions
docs/                     # Milestone documentation and guides
android/
  app/src/main/
    AndroidManifest.xml   # AdMob App ID + INTERNET permission
CLAUDE.md                 # AI session guide and templates
BUILD_LOG.md              # Command history with exact output
CHANGELOG.md              # Notable changes per milestone
```

---

## AdMob

The app uses Google AdMob for monetisation (Banner, Interstitial, Rewarded Video).
The current build uses **Google test ad unit IDs** — safe for development, zero real revenue.

**Before publishing:** follow the step-by-step instructions in
[docs/admob_setup_guide.md](docs/admob_setup_guide.md) to replace test IDs with your
real AdMob unit IDs and configure payment.

---

## Milestones

| # | Name | Status |
|---|---|---|
| 00 | Project Setup | Complete |
| 01 | Game Logic | Complete |
| 02 | Basic UI | Complete |
| 03 | Win Detection | Complete |
| 04 | AI Player & UI Polish | Complete |
| 05 | AdMob Integration | Complete |
| 06 | Polish (animations, sound, theming) | Pending |

See [BUILD_LOG.md](BUILD_LOG.md) for full session history and
[CHANGELOG.md](CHANGELOG.md) for a summary of changes per milestone.
