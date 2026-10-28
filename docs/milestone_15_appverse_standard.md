# Milestone 15 — App Verse Games Standard

**Date:** 2026-10-28
**Branch:** milestone/15-appverse-standard
**Status:** 🔄 Awaiting confirmation

Brings the game up to the App Verse Games standard in
`D:\Development\appverse-games-master-build-prompt.md` (Part B audit, then Part A in full).
Every ASK item was approved with the recommended option.

## Objectives

- [x] Pin behaviour before the refactor (existing 135 tests + Hard AI timing test)
- [x] Rebrand to App Verse Games: `com.appversegames.tictactoe` on Android, iOS and Windows;
      copyright headers; pubspec description; no `fullstackshack` left in code
- [x] Delete `linux/` and `macos/`; add the AdMob test App ID to `Info.plist`
- [x] Depend on `appverse_core_kit`: `CoreKit.init`, `AppverseTheme`, `kit.settings`,
      `kit.ads`, `kit.sound`, `AutoPlayController`, `isWebBuild`
- [x] Surakarta folder layout: `lib/game`, `lib/screens`, `lib/widgets`, `lib/services`
- [x] Mobile home page, How to Play, core-kit Settings; web opens straight into the game
- [x] First-move choice (you / computer / take turns); settings saved under `tictactoe.*`
- [x] Old score keys migrated to `tictactoe.score.*`
- [x] Synthesised sounds; generated icon; navy splash
- [x] Watch and Learn with move reasons, commentary, log, speed; pauses when hidden
- [x] Last-move highlight; rewarded-ad hint kept on Android
- [x] Sign in with Google scaffold (Portfolio Pass identity)
- [x] `web/embed.js`, updated `index.html`/`manifest.json`, `tool/build_web.ps1`
- [x] Ko-fi, Games Hub and play-time reminder kept on mobile in brand colours
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 196 tests, all pass
- [x] Web build, real-iframe screenshots, offline run and embed.js mock-page check

## What changed for players

| Area | Before | After |
|------|--------|-------|
| Mobile start | Straight into the game screen | Home page: vs Computer, 2 Players, Watch and Learn, How to Play, More Games, Settings, Ko-fi |
| Colours | Red/blue mobile theme, dark by default | Brand navy/amber/ivory; follows the system theme (Settings: System / Light / Dark) |
| Board | Theme-coloured cells | Navy board with an amber edge, ivory X, amber O, same in both themes |
| Who starts | Always the player (X) | You, the computer, or take turns; whoever starts plays X |
| Ads | Banner + interstitial every 3rd game + rewarded hint | Core kit: interstitial after some games (grace period, 3-minute gap) + rewarded hint. No banner |
| Sound | Haptics only | Synthesised sounds (mute in Settings) plus haptics |
| Privacy | Two-tab in-app policy | Short in-app note plus a link to https://appversegames.com/privacy-policy/ |
| Web | Mode and difficulty inline | New game, options dialog, demo, rules and theme buttons |

## AI reasons (Watch and Learn and vs Computer)

Every computer move is tagged with the first reason that really applies:
completes a line to win; blocks the opponent's line; makes two threats (fork); lines up one
threat; takes the centre; takes a corner; "looking ahead" fallback. Easy (and Medium's random
35%) say honestly "Picks a free square at random".

## Saved data (shared_preferences / localStorage)

`tictactoe.settings.*` (core kit: theme, sound, vibration), `tictactoe.setup.*` (mode, level,
first move, Watch and Learn levels and speed, who went first last), `tictactoe.score.*`, and
`tictactoe.identity.signedIn`. The privacy note says the same, and a test pins it.

## Notes

- The core kit has no banner ad, so the banner was dropped (approved under "ads through the
  core kit"). If you want it back, it belongs in `appverse_core_kit`, which needs your OK.
- Layout tests require a 280px board on web at every size; in the mobile app (app bar plus the
  play-time bar) the floor is 240px at 320×568.
- `flutter test --platform chrome` was not run (it has hung on this machine before); the web
  build was checked in real Chrome instead.
