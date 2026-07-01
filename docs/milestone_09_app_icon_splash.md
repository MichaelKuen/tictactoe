# Milestone 09 — Custom App Icon + Splash Screen

**Date:** 2026-07-01
**Branch:** milestone/09-app-icon-splash
**Status:** ✅ Complete

## Objectives

- [x] Generate custom 1024×1024 app icon (matching game branding)
- [x] Generate splash logo for native splash screen
- [x] `flutter_launcher_icons` — Android + iOS launcher icon sets
- [x] `flutter_native_splash` — Android (pre-12 + Android 12) + iOS, dark + light variants
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 80/80 pass

## Icon design

Generated with Python (Pillow) — no external design tool required.

| Element | Value |
|---|---|
| Canvas | 1024×1024 px, RGBA |
| Background | `#1A1A2E` (dark navy — matches app dark theme) |
| Grid lines | `#5A5A7A`, 8 px wide |
| X pieces | `#FF5252` (vivid red), top-left and bottom-right cells |
| O piece | `#40C4FF` (sky blue), centre cell |
| Line thickness | 28 px |

The icon shows a mid-game board (two Xs placed, one O in the centre) — immediately
recognisable as Tic Tac Toe without any text.

## Files generated

### `dart run flutter_launcher_icons`

| Platform | Output |
|---|---|
| Android | `android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` |
| iOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (all required sizes) |

`remove_alpha_ios: true` strips the alpha channel to meet App Store submission requirements.

### `dart run flutter_native_splash:create`

| Variant | Output |
|---|---|
| Android pre-12 (default) | `res/drawable/launch_background.xml` |
| Android pre-12 (dark) | `res/drawable-night/launch_background.xml` |
| Android 12+ (default) | `res/drawable-v21/launch_background.xml` + `res/values-v31/styles.xml` |
| Android 12+ (dark) | `res/drawable-night-v21/launch_background.xml` + `res/values-night-v31/styles.xml` |
| iOS | `ios/Runner/Assets.xcassets/LaunchImage.imageset/` |

All variants use background `#1A1A2E` with the centred splash logo.

## Updating the icon in future

Replace `assets/icon/app_icon.png` with a new 1024×1024 PNG, then re-run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

No other code changes needed.
