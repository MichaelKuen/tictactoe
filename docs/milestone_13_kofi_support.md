# Milestone 13 — Ko-fi Support Button

**Date:** 2026-07-26
**Branch:** milestone/13-kofi-support
**Status:** ✅ Complete

## Objectives

- [x] Ko-fi button visible on all platforms (Android, Web, iOS, macOS, Windows, Linux)
- [x] More visually prominent than surrounding UI elements
- [x] Shared widget — single source of truth for URL, colour, and label
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 98 tests, all pass

## New File

### `lib/ui/kofi_button.dart`

Shared `KoFiButton` stateless widget. Renders a full-width `FilledButton.icon` styled
with Ko-fi brand blue (`#72A4F2`) and a coffee icon. On tap, opens
`https://ko-fi.com/O3A423W17K` via `url_launcher` in an external browser on all
supported platforms.

```dart
FilledButton.icon(
  backgroundColor: Color(0xFF72A4F2),
  foregroundColor: Colors.white,
  icon: Icon(Icons.coffee),
  label: Text('Support on Ko-fi'),
)
```

No new dependencies — `url_launcher` was already present from Milestone 07.

## Placement

| Location | Position |
|----------|----------|
| Narrow layout (mobile/portrait) | Below New Game / Watch ad for hint buttons |
| Wide layout sidebar (desktop/web) | Below "More Games" button |
| Games Hub bottom sheet footer | First item — above "View all on Google Play" |

The button is placed as the most prominent item in each location by using a `FilledButton`
(filled background) while surrounding controls use `OutlinedButton` or text styles.

## Changed Files

| File | Change |
|------|--------|
| `lib/ui/game_screen.dart` | Import + `KoFiButton` in narrow layout and wide sidebar |
| `lib/ui/games_sheet.dart` | Import + `KoFiButton` as first item in sheet footer |
| `macos/Flutter/GeneratedPluginRegistrant.swift` | Auto-updated to register `SharedPreferencesPlugin` |
