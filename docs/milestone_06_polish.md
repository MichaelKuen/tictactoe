# Milestone 06 — Polish

**Date:** 2026-07-01
**Branch:** milestone/06-polish
**Status:** Complete

## Objectives

- [x] Light / dark theme toggle (sun/moon button in AppBar)
- [x] Cell piece-placement bounce animation (`Curves.elasticOut`, 400 ms)
- [x] Winning cell pulse animation (scale 1.0 → 1.05, 700 ms repeat)
- [x] Status text crossfade (`AnimatedSwitcher`, 250 ms)
- [x] Haptic feedback on moves, win, and draw
- [x] Sidebar and AppBar colours are theme-aware
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 76/76 pass

## What was added

### Theme system (`lib/theme_notifier.dart`)
A single `ValueNotifier<ThemeMode>` shared across the app without a state management
package. `TicTacToeApp` wraps `MaterialApp` with `ValueListenableBuilder` so the entire
tree rebuilds when the mode changes.

### Light theme
- X: deep red `#D32F2F` — still highly visible on white
- O: deep blue `#1565C0` — high contrast companion
- Cell background: `Colors.white` with grey outline

### Dark theme (unchanged colours, tidied into `_darkTheme`)
- X: vivid red `#FF5252`
- O: vivid sky blue `#40C4FF`
- Cell background: `#252540`

### Cell bounce (`lib/ui/cell_widget.dart`)
`CellWidget` is now a `StatefulWidget` with two `AnimationController`s:

| Controller | Purpose | Duration | Curve |
|---|---|---|---|
| `_placeCtrl` | Scale 0→1 when piece placed | 400 ms | `Curves.elasticOut` (bouncy) |
| `_pulseCtrl` | Scale 1.0→1.05 repeat on winning cells | 700 ms | `Curves.easeInOut` |

Controllers are initialised in `initState()` (not lazily) to prevent a Flutter error where a
deactivated widget's ancestor is accessed during disposal.

### Haptic feedback (`lib/ui/game_screen.dart`)
| Event | Haptic |
|---|---|
| Any cell tap (player or AI) | `HapticFeedback.selectionClick()` |
| Draw | `HapticFeedback.lightImpact()` |
| Win | `HapticFeedback.mediumImpact()` |
| New Game / reset | `HapticFeedback.lightImpact()` |

## Investigation note — board-level AnimatedSwitcher

A board-level `AnimatedSwitcher` (keyed by a `_boardKey` counter) was trialled for a
fade-out/fade-in effect on reset. It was removed because:

1. `AnimatedSwitcher` keeps both the old and new board in the widget tree simultaneously
   during the transition, causing `find.byKey(ValueKey('cell_N'))` to match two widgets and
   breaking all widget tests that tap cells after a reset.
2. Repeating pulse animations on winning cells cause `pumpAndSettle()` to loop indefinitely,
   making it impossible to safely wait for the switcher transition in tests.

The cell-level bounce animation on piece placement provides equivalent visual feedback without
these issues.
