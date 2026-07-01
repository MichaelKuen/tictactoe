# Milestone 07 — Games Hub

**Date:** 2026-07-01
**Branch:** milestone/07-games-hub
**Status:** ✅ Complete

## Objectives

- [x] `lib/games/game_entry.dart` — `GameEntry` data class with Play Store URL computation
- [x] `lib/games/games_catalog.dart` — master list + developer page URL constant
- [x] `lib/ui/games_sheet.dart` — draggable bottom sheet with game cards + footer
- [x] AppBar `Icons.sports_esports` button (both narrow and wide layouts)
- [x] Wide sidebar "More Games" `OutlinedButton.icon`
- [x] `url_launcher: ^6.3.2` added; Android HTTPS intent query added
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 76/76 pass

## What was built

### Game Entry model (`lib/games/game_entry.dart`)

`GameEntry` is a plain `const`-constructable class:

| Field | Type | Purpose |
|---|---|---|
| `name` | `String` | Display name |
| `tagline` | `String` | Short description |
| `icon` | `IconData` | Material icon |
| `iconColor` | `Color` | Icon / bubble colour |
| `playStoreId` | `String?` | Package ID — null = coming soon |
| `isCurrent` | `bool` | True for the running app |

Computed getters: `isReleased` (null-check on `playStoreId`) and `playStoreUrl`
(`https://play.google.com/store/apps/details?id=<id>`).

### Games catalog (`lib/games/games_catalog.dart`)

- `devPageUrl` — Google Play developer page for FullStackShack
- `fullStackShackGames` — starts with Tic Tac Toe (current, with Play Store ID) and
  a "More games coming soon!" placeholder (no ID → `isReleased == false`)

To add a new game in future:
1. Add a `GameEntry` with the correct `playStoreId`
2. No UI code changes needed — the sheet regenerates from the list automatically

### Games sheet (`lib/ui/games_sheet.dart`)

`GamesSheet.show(context)` opens a `showModalBottomSheet` that wraps a
`DraggableScrollableSheet` (initial 65 %, min 40 %, max 92 %).

| Section | Content |
|---|---|
| Header | `Icons.sports_esports` icon + "FullStackShack Games" title + close button |
| Card list | `_GameCard` per entry: icon bubble, name, tagline, action widget |
| Footer | "View all on Google Play" `OutlinedButton.icon` → `devPageUrl`; house-ads disclosure |

**Card action logic:**
- `isCurrent == true` → "Playing" outlined badge (primary colour)
- `isReleased == true` (but not current) → "Play" `FilledButton` → deep-link to Play Store
- Neither → "Soon" outlined badge (muted)

### Entry points in `game_screen.dart`

| Location | Widget | Trigger |
|---|---|---|
| AppBar actions | `IconButton(Icons.sports_esports)` | Both narrow and wide |
| Wide sidebar footer | `OutlinedButton.icon` "More Games" | Wide layout only |

## Notes

- `url_launcher` requires the HTTPS intent query in `AndroidManifest.xml` to open Play Store
  links on Android 11+ (package visibility restrictions)
- Theme awareness: sheet background `#1A1A2E` (dark) / `#F5F5F5` (light); card background
  `#252540` (dark) / `Colors.white` (light) — matches cell and sidebar colours throughout the app
- House-ads disclosure note in the sheet footer sets user expectations for cross-promotion ads
