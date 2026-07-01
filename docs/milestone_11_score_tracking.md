# Milestone 11 — Score Tracking

**Date:** 2026-07-01
**Branch:** milestone/11-score-tracking
**Status:** ✅ Complete

## Objectives

- [x] Track win / draw / loss counts per game mode (vs AI and vs Human separately)
- [x] Persist scores across app sessions using SharedPreferences
- [x] Display live scoreboard on screen in both narrow and wide layouts
- [x] Animated score number transitions (no jarring jumps)
- [x] Reset button to clear scores
- [x] Labels adapt to mode: YOU / AI (vs AI) or X / O (vs Human)
- [x] 7 unit tests for the Score data class
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 98 tests, all pass

## New Files

### `lib/game/score.dart`

Immutable data class. All mutation methods return a new instance.

```dart
class Score {
  final int xWins;
  final int oWins;
  final int draws;

  Score copyWithXWin()  // returns new Score with xWins + 1
  Score copyWithOWin()  // returns new Score with oWins + 1
  Score copyWithDraw()  // returns new Score with draws + 1
  Score get reset       // returns Score(0, 0, 0)
}
```

### `lib/game/score_repository.dart`

`SharedPreferences`-backed persistence. Separate key namespaces for vs-AI and vs-Human
so switching modes never overwrites the other mode's record.

```
Keys: score_ai_x, score_ai_o, score_ai_d
      score_hv_x, score_hv_o, score_hv_d
```

Created via `await ScoreRepository.create()` — async factory so the calling widget
does not block on `initState`.

### `lib/ui/score_widget.dart`

Three-column compact scoreboard: `[YOU/X] | [DRAW] | [AI/O]` with a small refresh icon.

- Background/border colours adapt to dark/light theme
- `AnimatedSwitcher` on each count so number changes animate (300 ms fade-swap)
- Labels driven by `vsAi` flag — no hardcoded strings

## Modified Files

### `lib/ui/game_screen.dart`

**Score state fields:**
```dart
ScoreRepository? _scoreRepo;   // null until async init completes
Score _aiScore = const Score();
Score _humanScore = const Score();
```

**`_initScores()`** — called in `initState`, awaits `ScoreRepository.create()`, then
`setState` to populate both score fields. Guard `if (!mounted)` before setState.

**`_recordResult()`** — called after every game-over event (both human tap and AI timer
callback). Uses switch expression on `_game.status` to select the correct increment
method. Saves to repo immediately (no await — fire-and-forget is fine for prefs).

**`_resetScores()`** — calls `repo.resetAll()` and `setState` to zero both in-memory scores.

**Placement:**
- Narrow layout: between the difficulty selector and the status text
- Wide sidebar: below the New Game button, above the "More Games" divider

## Dependency Added

```yaml
shared_preferences: ^2.3.2
```

Stable, official Flutter plugin. No additional Android/iOS configuration required
(uses `NSUserDefaults` on iOS, `SharedPreferences` on Android automatically).
