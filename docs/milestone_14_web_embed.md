# Milestone 14 — Web Embed for appversegames.com

**Date:** 2026-10-12
**Branch:** milestone/14-web-embed
**Status:** ✅ Complete (confirmed 2026-10-12)

## Objectives

- [x] Web build shows only the game inside the iframe at `https://appversegames.com/play/tictactoe/`
- [x] No ad SDK, store links, Ko-fi, privacy page or session timer on web
- [x] Layout fits every iframe size from 320px wide and down to 560px tall, with no scrolling
- [x] Site colours on web (light by default), dark mode toggle in the game controls
- [x] Keyboard play on desktop
- [x] Nothing loads from Google or any other host at runtime
- [x] Android and iOS behaviour pinned by tests before the refactor
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 135 tests, all pass

## How embed mode works

`GameScreen.embedMode` defaults to `kIsWeb`. Tests construct `GameScreen(embedMode: true)`
to exercise the web layout on the VM.

| Platform | Shows |
|----------|-------|
| Web (embed) | Mode, difficulty, status, board, score, New Game, theme toggle |
| Mobile | Unchanged: app bar, session bar, Games Hub, privacy, Ko-fi, ad hint, banner |

### Web layout (one `LayoutBuilder`)

- Side panel when the iframe is ≥ 720px wide **and** landscape; otherwise controls stack
  around the board.
- Board = min(available width, available height − controls, 560px).
- Every control row has a fixed height and a `FittedBox(scaleDown)`, so text shrinks instead
  of overflowing.

### Keyboard (web only)

| Key | Action |
|-----|--------|
| 1–9 | Cell in reading order (1 = top-left) |
| Numpad 1–9 | Cell in numpad layout (7 = top-left) |
| Arrows | Move cursor (first press selects the centre) |
| Enter / Space | Place at the cursor |
| N | New game |

The handler uses `HardwareKeyboard.instance.addHandler`, so keys keep working after a button
is clicked. Clicked controls release focus, and arrow keys are mapped to
`DoNothingAndStopPropagationIntent` app-wide in embed mode.

### Web theme colours

| Role | Light | Dark |
|------|-------|------|
| Background | `#F6F3EC` ivory | `#16193A` navy |
| X | `#16193A` navy | `#F2A541` amber |
| O | `#0B6B63` teal | `#5FD4C4` light teal |
| Winning line / cursor | `#F2A541` amber | amber / ivory |

## Mobile sizing fixes (all platforms)

- Removed the empty 180px spacer that squeezed the board in the wide layout.
- Sidebar only at ≥ 720px wide and landscape (was ≥ 600px), which fixes the 600–720px band.
- The board takes the largest square available (the old 400px cap had no effect).
- The narrow layout scrolls rather than shrinking the board below 240px on short phones.
- The X/O glyph scales with the cell size.

## Web files

- `web/index.html` — title, description, viewport, theme-color, ivory background, loading
  spinner, `touch-action: pan-y` so swipes over the game scroll the host page.
- `web/flutter_bootstrap.js` — removes the spinner after `runApp()`; no service worker.
- `web/manifest.json` — names, description, site colours.
- `web/.htaccess` — MIME types, deflate, `no-cache` for build files, `no-store` for
  `index.html`. No `immutable` or long expiry, because Flutter file names are not hashed.

## Build and verification

```
flutter build web --release --base-href /play/tictactoe/ --no-web-resources-cdn
```

| | Before (default build) | After |
|---|---|---|
| `main.dart.js` | 2,296,216 bytes | 2,032,535 bytes |
| `build/web` total | 40 MB | 41,502,152 bytes (canvaskit 37,851,412, now served locally) |
| Bundled images | splash + icon (~40 KB) | none |
| Roboto | fetched from fonts.gstatic.com | `assets/fonts/fallback/Roboto-Regular.ttf` |

- Iframe screenshots at 320, 600 and 1024px wide rendered correctly (headless Chrome).
- A run with every host except 127.0.0.1 unresolvable rendered byte-identical to the online
  run; the server log shows only local requests.

## Notes

- **Real phone check still needed** for `touch-action: pan-y` (scrolling the page by swiping
  over the game). Headless Chrome cannot test touch scrolling.
- On WordPress, keep the iframe shorter than the screen, e.g. `height: min(700px, 80svh)`, and
  do not place an ad unit directly under the New Game button.
- Scores on web are stored in the browser's localStorage (`flutter.score_ai_x`, etc.); the site
  privacy policy should mention this.
- Not changed: Hard AI is deterministic; score reset has no confirmation; the in-app privacy
  text says "Android SharedPreferences" on every platform.
