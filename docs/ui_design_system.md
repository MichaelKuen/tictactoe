# FullStackShack UI Design System

This document captures the exact UI conventions used in the FullStackShack Tic Tac Toe app
(`com.fullstackshack.tictactoe`). Paste this prompt at the start of any new FullStackShack
game app session to apply consistent UI across the suite. Where a feature doesn't exist in
the new app (e.g. no AI, no scores), omit the relevant component but keep all shared
foundations intact. We are trying to maintain a consistent look, feel across all apps, trying to maintain links, buttons in similar/same place, while this may not be possible on all apps due to the fact that some apps will have more / less necessary features. 

---

## 1. Theme Setup (`main.dart`)

Use Material 3. Default to dark mode. Wire a global `ValueNotifier<ThemeMode>` called
`themeNotifier` (in `lib/theme_notifier.dart`) so any widget can toggle the theme.

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

## 3. Responsive Layout (LayoutBuilder breakpoint: 600 px)

### Narrow (\<600 px) — Column layout

- Outer padding: `EdgeInsets.all(24)`
- Order (top to bottom):
  1. Mode selector (`SegmentedButton`)
  2. Sub-option selector if applicable (e.g. difficulty) — only when relevant mode active
  3. Score widget (if scores exist)
  4. Status text (`AnimatedSwitcher`, `headlineMedium`)
  5. Game board (`Flexible` + `AspectRatio` 1:1, `maxWidth`/`maxHeight` 400)
  6. Primary action button (`FilledButton` — e.g. "New Game")
  7. Secondary optional action (`OutlinedButton.icon` — e.g. hint)

### Wide (≥600 px) — Sidebar layout

- Left spacer: 180 px (mirrors sidebar width for visual centering)
- Centre: game board + status, padding `EdgeInsets.all(32)`
- Right sidebar: 180 px wide
  - Background: `isDark ? Color(0xFF252540) : Color(0xFFEEEEEE)`
  - Border: `Border(left: BorderSide(color: sidebarBorderColor))` where
    `sidebarBorderColor = isDark ? Color(0xFF5A5A7A) : Color(0xFFCCCCCC)`
  - Padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 24)`
  - Content: section labels (`labelMedium`, 50% opacity, `letterSpacing: 1.2`) above
    groups of `_SidebarButton` widgets (`FilledButton` when selected / `OutlinedButton`
    when not), separated by `Divider`s.
  - Bottom of sidebar: "More Games" `OutlinedButton.icon`, then score widget.

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

## 6. Hardcoded Semantic Colours (used regardless of theme)

| Purpose                 | Background  | Foreground / Border |
|-------------------------|-------------|---------------------|
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
| Narrow outer pad    | 24 px  |
| Wide centre pad     | 32 px  |
| Sidebar width       | 180 px |
| Sidebar inner pad   | `symmetric(horizontal: 16, vertical: 24)` |
| Between major sections | 16–24 px |
| Between related items  | 8–12 px  |
| Card inner padding  | 14–16 px |
| Board max dimension | 400×400  |

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
- **Always include**: theme system, AppBar pattern, responsive layout, Games Hub sheet,
  Privacy Policy screen, copyright headers, and branch/commit conventions from `CLAUDE.md`.
- Adjust status text logic and board/game widget for the specific game's state model.
