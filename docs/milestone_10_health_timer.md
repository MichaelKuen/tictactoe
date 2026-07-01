# Milestone 10 — Health Awareness Timer

**Date:** 2026-07-01
**Branch:** milestone/10-health-timer
**Status:** ✅ Complete

## Objectives

- [x] Display elapsed play time on the main screen at all times
- [x] Countdown to next recommended break
- [x] 20-minute eye-break reminder (20-20-20 rule — AOA guideline)
- [x] 60-minute session-limit alert (WHO/NHS screen-time guideline)
- [x] Warning zone 5 minutes before each break (colour ramp-up)
- [x] Smooth colour transitions (green → amber → red)
- [x] Non-intrusive UI — always visible but doesn't obstruct gameplay
- [x] Unit tests for all timer logic
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 91 tests, all pass

## Health Guidelines Used

| Guideline | Source | Implementation |
|-----------|--------|----------------|
| 20-20-20 eye rule | American Optometric Association (AOA) | 20-min snackbar: "look 20 ft away for 20 s" |
| 60-min session limit | WHO / NHS digital health recommendations | 60-min modal dialog, non-dismissible, recommends a proper break |
| 5-min warning ramp-up | General UX best practice | Warning state starts 5 min before each break |

## New Files

### `lib/health/session_timer.dart`

`SessionTimer extends ChangeNotifier` driven by `Timer.periodic(Duration(seconds: 1))`.

```
HealthState enum:
  safe            — 0–14:59 and 20:01–54:59
  warning         — 15:00–19:59 and 55:00–59:59
  eyeBreakDue     — ≥ 20 min, eye-break not yet acknowledged
  sessionLimitDue — ≥ 60 min, session limit not yet dismissed
```

Key API:
- `elapsed` — seconds since start
- `timeUntilBreak` — seconds until next break target
- `state` — current `HealthState`
- `acknowledgeEyeBreak()` — marks eye break seen, shifts target to 60 min
- `acknowledgeSessionLimit()` — resets elapsed to 0 (user took a break)
- `dismissSessionLimit()` — marks dialog seen without resetting (continue anyway)

### `lib/ui/session_bar_widget.dart`

Compact bar inserted between AppBar and game content. Uses `ListenableBuilder` so it reacts to
every `SessionTimer` tick without rebuilding the full screen.

- `AnimatedContainer` with 400 ms colour transition
- `_PulsingDot` — opacity animation active only in `warning` state

## Modified Files

### `lib/ui/game_screen.dart`

- `_sessionTimer` started in `initState`, listener `_onTimerTick` checks flags
- Eye-break fires once at 20 min as an 8-second amber `SnackBar`
- Session-limit fires once at 60 min as a non-dismissible `AlertDialog` with two actions:
  - **Take a break** (recommended) — resets timer, resets shown flags
  - **Continue anyway** — marks seen, timer stays red
- Body structure: `SafeArea → Column([SessionBarWidget, Expanded(LayoutBuilder)])`
- Wide-layout sidebar: reduced `SizedBox(32)` spacers around New Game section to `SizedBox(8)` —
  keeps button visible in constrained viewports (fixes test hit-test failure)

### `lib/ui/cell_widget.dart`

Fixed `didUpdateWidget` board-clear logic. The previous `_placeCtrl.value = 0` notified
`ScaleTransition` listeners mid-reconciliation, scheduling an extra render frame that prevented
`find.text('X')` from returning nothing after a reset. Changed to:
```dart
_placeCtrl.stop();
_placeCtrl.reset();
```

## Notes

The `SessionTimer` starts automatically when `GameScreen` mounts and runs continuously — it tracks
total time on screen, not time per move. If the user navigates away (app minimised), the timer still
ticks because it uses `Timer.periodic` (no lifecycle pause). A future enhancement could pause the
timer on `AppLifecycleState.paused`.
