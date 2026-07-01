# Milestone 08 — AI Difficulty + Release Prep

**Date:** 2026-07-01
**Branch:** milestone/08-release-prep
**Status:** ✅ Complete

## Objectives

- [x] `Difficulty` enum — easy, medium, hard
- [x] `AiPlayer.move()` — dispatches to random / mixed / minimax per difficulty
- [x] Difficulty selector in narrow layout (SegmentedButton, vs AI mode only)
- [x] Difficulty section in wide sidebar (3 SidebarButtons, scrollable column)
- [x] 4 new unit tests covering all difficulty modes
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 80/80 pass

## AI difficulty design

| Level | Behaviour | Feel |
|---|---|---|
| Easy | Always picks a random empty cell | Beatable by anyone; great for kids |
| Medium | 35 % random, 65 % minimax | Makes mistakes; competitive for casual players |
| Hard | Full minimax (unbeatable) | No human can win — original behaviour |

Default on launch: **Hard** (preserves prior behaviour).
Changing difficulty resets the board immediately and cancels any pending AI timer.

## Overflow fix — wide sidebar

Adding the difficulty section (3 buttons + label + dividers + spacing) pushed the sidebar
column past its available height in the test harness (480 px) and on short real screens.

Fix: wrapped the sidebar `Column` in `SingleChildScrollView` with `mainAxisSize: MainAxisSize.min`.
This lets the content flow as long as it needs and scroll if the screen is shorter than the content,
without changing visual appearance on normal-sized screens.

## Release prep checklist

Before submitting to the Google Play Store:

### Code
- [ ] Replace test AdMob IDs with real IDs — see [admob_setup_guide.md](admob_setup_guide.md)
- [ ] Set real AdMob App ID in `AndroidManifest.xml`
- [ ] Update `pubspec.yaml` version to `1.0.0+1`

### Assets
- [ ] Replace default Flutter launcher icon with custom icon
  - Tool: `flutter_launcher_icons` package
  - Icon size: 1024×1024 px, PNG, no transparency (Play Store requirement)
- [ ] Replace default Flutter splash screen
  - Tool: `flutter_native_splash` package

### Play Store listing
- [ ] App title: `Tic Tac Toe`
- [ ] Short description (80 chars max): `Challenge the AI or a friend — 3 difficulty levels`
- [ ] Full description (4000 chars max)
- [ ] Screenshots: phone (min 2), 7-inch tablet (optional), 10-inch tablet (optional)
- [ ] Feature graphic: 1024×500 px
- [ ] Content rating questionnaire (no violence, no ads targeting children)

### Privacy policy
- [ ] Host a privacy policy URL (required for apps with ads)
  - Minimum content: what data is collected (AdMob collects device advertising ID), how it is used
  - Free hosting option: GitHub Gist or GitHub Pages

### Build
```bash
flutter build apk --release          # signed APK
flutter build appbundle --release    # preferred for Play Store (AAB)
```
Requires a keystore — generate once:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```
Then configure `android/key.properties` and `android/app/build.gradle` — see
[Flutter docs: Create upload keystore](https://docs.flutter.dev/deployment/android#create-an-upload-keystore).

### Final checks
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all pass
- [ ] Install release APK on a real device and test end-to-end
- [ ] Confirm ads appear (banner, interstitial after 3 games, rewarded hint)
- [ ] Do NOT click your own ads
