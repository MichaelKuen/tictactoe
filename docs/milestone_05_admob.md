# Milestone 05 — AdMob Integration

**Date:** 2026-07-01
**Branch:** milestone/05-admob
**Status:** Complete

## Objectives

- [x] Add `google_mobile_ads` package
- [x] Configure `AndroidManifest.xml` (INTERNET permission + App ID)
- [x] Initialise AdMob SDK before `runApp()`
- [x] Banner ad — always-on at the bottom of the screen
- [x] Interstitial ad — shown automatically every 3rd game over
- [x] Rewarded video ad — shown on demand via "Watch ad for hint" button
- [x] Hint highlights optimal cell in green after reward is earned
- [x] Ads suppressed on Web and Windows (platform guard)
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 76/76 pass

## Architecture

```
AdManager (singleton)
  ├── initialize()         — calls MobileAds.instance.initialize(), preloads ads
  ├── onGameEnded()        — increments counter; shows interstitial on every 3rd call
  ├── showRewarded(cb)     — shows rewarded ad, fires cb when user earns reward
  └── isRewardedReady      — whether a rewarded ad is loaded and waiting

GameScreen
  ├── BannerAd             — owned here, disposed with the widget
  ├── _hintCell (int?)     — index of the green-highlighted hint cell
  └── _HintButton          — shown only while playing; calls AdManager.showRewarded
```

## Ad unit IDs (test — replace before release)

| Format | Android | iOS |
|---|---|---|
| App ID | `ca-app-pub-3940256099942544~3347511713` | `ca-app-pub-3940256099942544~1458002511` |
| Banner | `ca-app-pub-3940256099942544/6300978111` | `ca-app-pub-3940256099942544/2934735716` |
| Interstitial | `ca-app-pub-3940256099942544/1033173712` | `ca-app-pub-3940256099942544/4411468910` |
| Rewarded | `ca-app-pub-3940256099942544/5224354917` | `ca-app-pub-3940256099942544/1712485313` |

## Before releasing to production

1. Create a real AdMob account at admob.google.com
2. Register the app and create three ad units (Banner, Interstitial, Rewarded)
3. Replace all test IDs above with the real unit IDs
4. Replace the test App ID in `AndroidManifest.xml` with the real App ID
5. Add real iOS App ID to `ios/Runner/Info.plist` under `GADApplicationIdentifier`

## Notes

- `google_mobile_ads` v9.0.0 does not support Web or Windows — the `_adsSupported` guard
  (`!kIsWeb && (android || iOS)`) ensures ad code is never reached on unsupported platforms.
- The banner ad is managed by `GameScreen` (not `AdManager`) so it is properly disposed when
  the widget is removed from the tree.
- Interstitial and rewarded ads are preloaded immediately after each show so the next one is
  ready by the time the player needs it.
- Google enforces a 60-second minimum between interstitials; the every-3rd-game trigger is an
  additional app-level guard that keeps the experience friendly.
