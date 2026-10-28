# FullStackShack UI Design System

> **Superseded (2026-10-28, milestone 15).** Tic Tac Toe now follows the App Verse Games
> standard in `D:\Development\appverse-games-master-build-prompt.md`: brand colours and themes
> come from `appverse_core_kit` (`AppverseColors`, `AppverseTheme`), and the FullStackShack
> colours, `themeNotifier`, `web_theme.dart` and `BoardColors` described below no longer exist.
> Kept as history only.

This document captures the exact UI conventions used in the FullStackShack Tic Tac Toe app
(`com.fullstackshack.tictactoe`). Paste this prompt at the start of any new FullStackShack
game app session to apply consistent UI across the suite. Where a feature doesn't exist in
the new app (e.g. no AI, no scores), omit the relevant component but keep all shared
foundations intact. We are trying to maintain a consistent look, feel across all apps, trying to maintain links, buttons in similar/same place, while this may not be possible on all apps due to the fact that some apps will have more / less necessary features. 

---

## 1. Theme Setup (`main.dart`)

Use Material 3. Default to dark mode on mobile and light mode on web
(`kIsWeb ? ThemeMode.light : ThemeMode.dark`). Wire a global `ValueNotifier<ThemeMode>` called
`themeNotifier` (in `lib/theme_notifier.dart`) so any widget can toggle the theme.

The tables below are the **mobile** themes. The web build uses its own themes in the
appversegames.com site colours: see [section 13](#13-web-build-appversegamescom-iframe).
In `main.dart`: `theme: kIsWeb ? webLightTheme : _lightTheme`, and the same for `darkTheme`.

### Light theme — `ColorScheme.light`

| Role           | Value     |
|----------------|-----------|
| primary        | `#D32F2F` |
| onPrimary      | `#FFFFFF` |
| secondary      | `#1565C0` |
| onSecondary    | `#FFFFFF` |
| surface        | `#F5F5F5` |
| onSurface      | `#1A1A1A` |
| outline        | `#BDBDBD` |
| inversePrimary | `#EEEEEE` |

### Dark theme — `ColorScheme.dark`

| Role           | Value     |
|----------------|-----------|
| primary        | `#FF5252` |
| onPrimary      | `#FFFFFF` |
| secondary      | `#40C4FF` |
| onSecondary    | `#002233` |
| surface        | `#1A1A2E` |
| onSurface      | `#E0E0E0` |
| outline        | `#5A5A7A` |
| inversePrimary | `#2A2A4A` |

---

## 2. AppBar

- Title: app name as plain `Text`.
- Background: `isDark ? Color(0xFF252540) : Color(0xFFEEEEEE)` (matches sidebar).
- Standard trailing icons (include whichever apply to this app):
  - `Icons.sports_esports` → opens Games Hub bottom sheet
  - `Icons.privacy_tip_outlined` → opens Privacy Policy screen
  - `Icons.dark_mode` / `Icons.light_mode` → toggles `themeNotifier`

---

## 3. Responsive Layout (mobile)

Sidebar only when the space is **≥ 720 px wide and landscape**
(`maxWidth >= 720 && maxWidth > maxHeight`); otherwise the narrow column. A fixed 600 px
breakpoint squeezed the board between 600 and 720 px.

### Narrow — Column layout

- Outer padding: `EdgeInsets.symmetric(horizontal: 24, vertical: 16)`
- Order (top to bottom):
  1. Mode selector (`SegmentedButton`)
  2. Sub-option selector if applicable (e.g. difficulty) — only when relevant mode active
  3. Score widget (if scores exist)
  4. Status text (`AnimatedSwitcher`, `headlineMedium`)
  5. Game board — fixed square computed from the `LayoutBuilder`:
     `min(width − 48, max(height − 400, 240), 560)`
  6. Primary action button (`FilledButton` — e.g. "New Game")
  7. Secondary optional action (`OutlinedButton.icon` — e.g. hint)
  8. Ko-fi button
- Wrap the column in `SingleChildScrollView` + `ConstrainedBox(minHeight: maxHeight)` +
  `Center`: it stays centred when it fits and scrolls on very short phones instead of shrinking
  the board below 240 px.

### Wide — Sidebar layout

- No left spacer (a mirrored spacer wastes 180 px of board space)
- Centre: game board + status, padding `EdgeInsets.all(32)`; the board is the largest square
  that fits (`Flexible` + `LayoutBuilder`, max 560 px)
- Right sidebar: 180 px wide
  - Background: `isDark ? Color(0xFF252540) : Color(0xFFEEEEEE)`
  - Border: `Border(left: BorderSide(color: sidebarBorderColor))` where
    `sidebarBorderColor = isDark ? Color(0xFF5A5A7A) : Color(0xFFCCCCCC)`
  - Padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 24)`
  - Content: section labels (`labelMedium`, 50% opacity, `letterSpacing: 1.2`) above
    groups of `_SidebarButton` widgets (`FilledButton` when selected / `OutlinedButton`
    when not), separated by `Divider`s.
  - Wrap the content in `SingleChildScrollView`.
  - Order: mode, difficulty, New Game, hint, score widget, then "More Games"
    `OutlinedButton.icon` and the Ko-fi button at the bottom.

### Board

- Build the grid from `Column`/`Row`/`Expanded`, not `GridView`, so the board is never a
  scrollable and always fills the square it is given.
- Piece glyph size follows the cell: `fontSize = cellShortestSide * 0.5`, `height: 1.0`.

---

## 4. Reusable Component Patterns

### `_SidebarButton`

- Selected state → `FilledButton` with `disabledBackground/ForegroundColor` matching
  primary colours (so it looks "active" even when `onPressed: null`).
- Unselected state → `OutlinedButton` with `BorderSide(color: outline)`.

### Cards (game cards, summary items, etc.)

- Background: `isDark ? Color(0xFF252540) : Colors.white`
- Border: `Border.all(color: theme.colorScheme.outline)` — use primary colour for
  the "active/current" card variant.
- Border radius: `12`
- Padding: `EdgeInsets.all(14)` or `EdgeInsets.all(16)`

### Icon bubble (inside cards)

- Size: 54×54 (or 44×44 for smaller contexts)
- Background: `iconColor.withValues(alpha: 0.12–0.15)`
- Border radius: `12` (or `10` for smaller)
- Icon size: `28` (or `22` for smaller)

### Badge ("Playing" / "Soon")

- Outlined pill: `BorderRadius.circular(20)`
- Padding: `symmetric(horizontal: 10, vertical: 5)`
- Text: `fontSize: 12`, `fontWeight: w600`, same colour as border.

### Score widget (if the app tracks scores)

- Background: `isDark ? Color(0xFF1E1E38) : Color(0xFFF0F0F0)`
- Border: `isDark ? Color(0xFF3A3A5A) : Color(0xFFD0D0D0)`
- Border radius: `10`
- Three cells: Player1 | DRAW | Player2 — each with tiny ALL-CAPS label (9 px, w700,
  `letterSpacing: 1.0`) and large animated number (22 px bold).
- Reset icon: `Icons.refresh`, 16 px, 30% opacity.
- Animate score changes with `AnimatedSwitcher(duration: 300 ms)`.

---

## 5. Animation Conventions

| Interaction               | Widget / Controller          | Duration | Curve                      |
|---------------------------|------------------------------|----------|----------------------------|
| Piece / token placement   | `ScaleTransition`, elasticOut | 400 ms  | `Curves.elasticOut`        |
| Winning-cell pulse        | `ScaleTransition`, repeat reverse | 700 ms | `Curves.easeInOut` (1.0 → 1.05) |
| Status text change        | `AnimatedSwitcher`           | 250 ms   | default                    |
| Health bar colour change  | `AnimatedContainer`          | 400 ms   | default                    |
| Pulsing dot (warning)     | `FadeTransition`, repeat reverse | 800 ms | `Curves.easeInOut` (0.4 → 1.0) |

Use `HapticFeedback`:
- `selectionClick()` — on any user move / tap
- `lightImpact()` — on reset or draw
- `mediumImpact()` — on win

---

## 6. Hardcoded Semantic Colours (mobile, used regardless of theme)

Board colours (cell, winning highlight, keyboard cursor) come from the optional `BoardColors`
theme extension when the theme provides one, which the web themes do (section 13). The values
below are the fallbacks used on mobile.

| Purpose                 | Background  | Foreground / Border |
|-------------------------|-------------|---------------------|
| Cell                    | `isDark ? #252540 : white` | `outline`, 1 px |
| Winning-cell highlight  | `#44FFD740` | `#FFD740`           |
| Hint cell               | `#4469F0AE` | `#69F0AE`           |
| Hint / rewarded button  | —           | `#69F0AE`           |
| Take-a-break button     | `#69F0AE`   | black               |
| Session bar — safe      | `#1B3A2F`   | `#69F0AE`           |
| Session bar — warning   | `#3A2D0A`   | `#FFD740`           |
| Session bar — danger    | `#3A0F0F`   | `#FF5252`           |
| Eye-break snackbar      | `#3A2D0A`   | `#FFD740`           |
| Session-limit dialog bg | `#1A1A2E`   | —                   |

---

## 7. Health / Session Bar (if included)

Shown between the `AppBar` and main content (above the game area, inside `SafeArea`).
Displays: elapsed time played · pulsing dot · countdown to next break.
Colour states: safe (green) → warning (amber, pulsing dot) → danger (red).
Trigger snackbar at 20 min (eye break); trigger dialog at 60 min (session limit).
Dialog has "Continue anyway" (`TextButton`, 38% opacity white) and
"Take a break" (`FilledButton`, `#69F0AE` bg, black text).

---

## 8. Games Hub Bottom Sheet

Triggered from AppBar icon and sidebar button.
Uses `showModalBottomSheet` with `backgroundColor: Colors.transparent` +
`DraggableScrollableSheet(initial: 0.65, min: 0.4, max: 0.92)`.
Sheet background: `isDark ? Color(0xFF1A1A2E) : Color(0xFFF5F5F5)`
Top border radius: `20`. Drag handle: 40×4, `outline` colour, radius `2`.
Header: `Icons.sports_esports` + "FullStackShack Games" (`titleLarge` bold) + close icon.
Game cards: icon bubble + name (`titleMedium` bold) + tagline (`bodySmall`, 60% opacity) +
badge/button (Playing / Play / Soon).
Footer: "View all on Google Play" `OutlinedButton.icon` + house-ads note (`bodySmall`, 40%
opacity) + "Privacy Policy" inline link (primary colour, underlined).

---

## 9. Privacy Policy Screen

Full-screen `Scaffold` with `DefaultTabController(length: 2)` and `TabBar`:
- Tab 1 — Summary: icon-tinted cards (`_SummaryItem` pattern)
- Tab 2 — Full Policy: numbered sections (`_PolicySection` / `_PolicySubSection`)

`TabBar` indicator and label colour: `theme.colorScheme.primary`.
Effective-date banner at top of Summary: `isDark ? Color(0xFF1E1E38) : Color(0xFFE8EAF6)`,
border `isDark ? Color(0xFF3A3A5A) : Color(0xFFC5CAE9)`, info icon `Color(0xFF7986CB)`.
Section headings: `titleMedium` bold, primary colour.
Body text: `bodyMedium`, `height: 1.65`, 85% opacity.
Contact section: `OutlinedButton.icon` to launch `mailto:` URI.

---

## 10. Spacing & Layout Constants

| Token               | Value  |
|---------------------|--------|
| Base unit           | 8 px   |
| Narrow outer pad    | 24 px horizontal, 16 px vertical |
| Wide centre pad     | 32 px  |
| Sidebar width       | 180 px |
| Sidebar breakpoint  | ≥ 720 px wide **and** landscape |
| Sidebar inner pad   | `symmetric(horizontal: 16, vertical: 24)` |
| Between major sections | 16–24 px |
| Between related items  | 8–12 px  |
| Card inner padding  | 14–16 px |
| Board max dimension | 560×560  |
| Board min (narrow mobile) | 240 px, column scrolls below that |

Web embed constants are in section 13.

---

## 11. Copyright Header

Every `.dart` file in `lib/` and `test/` must begin with:

```dart
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
```

No blank line before the first import. Do not add headers to generated files.

---

## 12. Notes on Adaptation

- **No AI opponent** — omit difficulty selector and hint button.
- **No persistent scores** — omit `ScoreWidget` and `ScoreRepository`.
- **No ads** — omit `AdManager`, banner widget, and hint rewarded flow.
- **No health session concern** — omit `SessionBarWidget` and session dialogs.
- **Always include on mobile**: theme system, AppBar pattern, responsive layout, Games Hub
  sheet, Privacy Policy screen, copyright headers, and branch/commit conventions from
  `CLAUDE.md`.
- **On web** the game is embedded in appversegames.com: leave out the AppBar, Games Hub,
  Privacy Policy, Ko-fi, ads and session timer, and follow section 13.
- Adjust status text logic and board/game widget for the specific game's state model.

---

## 13. Web Build (appversegames.com iframe)

The web build is embedded in an iframe at `https://appversegames.com/play/<name>/`. The page
around it already shows the title, rules and ads, so the web build shows **only the game**.
Gate it with an `embedMode` flag that defaults to `kIsWeb`
(`const GameScreen({super.key, this.embedMode = kIsWeb})`), so widget tests can drive the web
layout on the VM with `embedMode: true`.

### Site colours

| Name   | Hex       | Used for |
|--------|-----------|----------|
| Ivory  | `#F6F3EC` | Page and game background |
| Navy   | `#16193A` | Headings, text, X (light), primary buttons |
| Amber  | `#F2A541` | Accent: selected segments, winning line, cursor, X (dark) |
| Teal   | `#0B6B63` | Links, O (light) |

### Web themes (`lib/ui/web_theme.dart`)

Material 3. Web starts **light**; a theme toggle sits in the game controls because there is no
AppBar. Set `scaffoldBackgroundColor` to the surface colour.

**`webLightTheme` — `ColorScheme.light`**

| Role                 | Value     | Notes |
|----------------------|-----------|-------|
| primary              | `#16193A` | X, New Game button |
| onPrimary            | `#FFFFFF` | |
| secondary            | `#0B6B63` | O |
| onSecondary          | `#FFFFFF` | |
| secondaryContainer   | `#F9DDB0` | Selected segment (amber tint) |
| onSecondaryContainer | `#16193A` | |
| surface              | `#F6F3EC` | Ivory |
| onSurface            | `#16193A` | |
| outline              | `#CFC7B5` | Cell and segment borders |

**`webDarkTheme` — `ColorScheme.dark`**

| Role                 | Value     | Notes |
|----------------------|-----------|-------|
| primary              | `#F2A541` | X, New Game button |
| onPrimary            | `#16193A` | |
| secondary            | `#5FD4C4` | O (teal lightened for contrast on navy) |
| onSecondary          | `#16193A` | |
| secondaryContainer   | `#3B3F6B` | Selected segment |
| onSecondaryContainer | `#F6F3EC` | |
| surface              | `#16193A` | Navy |
| onSurface            | `#F6F3EC` | |
| outline              | `#3B3F6B` | |

**`BoardColors` extension (`lib/ui/board_colors.dart`)**

| Field         | Light       | Dark        |
|---------------|-------------|-------------|
| cell          | `#FFFFFF`   | `#22264D`   |
| highlight     | `#F2A541`   | `#F2A541`   |
| highlightFill | `#55F2A541` | `#44F2A541` |
| cursor        | `#F2A541`   | `#F6F3EC`   |

Keep the board pieces in strong colours (navy/teal on white, amber/light teal on navy). Plain
amber is too light for text on white, so use it only for borders, fills and selection.

### What to hide on web

AppBar and title, Games Hub / "More Games", Privacy Policy, store links, Ko-fi, ads and any
ad-gated feature (e.g. "Watch ad for hint"), and the health session bar and break reminders
(don't start the timer). No ad SDK may load on web. Open straight into the game; there is no
home screen.

### Layout (one `LayoutBuilder`)

- **Side panel** when the iframe is ≥ 720 px wide and landscape; otherwise controls stacked
  around the board.
- **Board** = `min(available width, available height − controls, 560)`.
- Every control row has a **fixed height** and a `FittedBox(fit: BoxFit.scaleDown)`, so text
  shrinks instead of overflowing. No empty spacers, nothing scrollable.
- `SegmentedButton(showSelectedIcon: false)` to save width.
- Must fit 320 px wide and down to 560 px tall; target sizes: 320×568 to 1280×700, plus
  1024×500 and 844×390. Board ≥ 280 px (≥ 400 px when the shortest side is ≥ 600 px).

| Token            | Value |
|------------------|-------|
| Outer padding    | 12 px |
| Gap between rows | 8 px  |
| Control row      | 40 px |
| Status row       | 32 px |
| Bottom row (score + New Game) | 52 px |
| Side panel width | 240 px (whole panel in a `FittedBox`) |
| Board max        | 560 px |

**Stacked order:** [mode selector + theme icon] → [difficulty, or "Two players, one device"
at the same height so the board doesn't jump] → status → board → [score + New Game].

**Side panel order:** status → MODE → DIFFICULTY (`labelMedium`, 70% opacity,
`letterSpacing: 1.2`) → score → New Game → "Dark mode" / "Light mode" `TextButton.icon`.

### Keyboard (web)

| Key           | Action |
|---------------|--------|
| 1–9           | Cell in reading order (1 = top-left) |
| Numpad 1–9    | Cell in numpad layout (7 = top-left) |
| Arrows        | Move a cursor; the first press selects the centre |
| Enter / Space | Act at the cursor |
| N             | New game |

- Use `HardwareKeyboard.instance.addHandler` in `initState` (remove in `dispose`), not a
  focus-based `KeyboardListener`, so keys keep working after a button is clicked.
- Ignore keys while a dialog is open (`ModalRoute.of(context)?.isCurrent`).
- After a control is clicked, call `FocusManager.instance.primaryFocus?.unfocus()` so
  Enter/Space don't press that button again.
- Map the arrow keys to `DoNothingAndStopPropagationIntent` in `MaterialApp.shortcuts` on web,
  so they don't move focus between buttons.
- Show the cursor as a 3 px border in `BoardColors.cursor`.

### Web files

- `web/index.html`: real title and meta description, viewport, `theme-color: #F6F3EC`, ivory
  `body` background, and a CSS spinner in `#loading` ("Loading <Game>…", navy text, amber arc).
- `touch-action: pan-y !important` on `html, body, flutter-view, flt-glass-pane`, so swipes over
  the game scroll the host page (only for games without drag gestures).
- Custom `web/flutter_bootstrap.js` that removes `#loading` after `appRunner.runApp()`; no
  service worker.
- `web/manifest.json`: real name and description, ivory `background_color` and `theme_color`.
- `web/.htaccess`: `no-cache` for build files and `no-store` for `index.html`; never
  `immutable` or long expiry (Flutter file names are not hashed).
- No emoji in the UI (it makes Flutter web download an emoji font).
- Build: `flutter build web --release --base-href /play/<name>/ --no-web-resources-cdn`
  (run from PowerShell; Git Bash rewrites `/play/...` into a Windows path).
