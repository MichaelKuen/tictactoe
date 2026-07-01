# AdMob Setup Guide — Tic Tac Toe

This guide walks you through replacing the Google **test** ad unit IDs with your real production
IDs before publishing the app. Complete every step in order.

> **Related files:** See [milestone_05_admob.md](milestone_05_admob.md) for the technical
> implementation details and [CHANGELOG.md](../CHANGELOG.md) for what was added in v0.6.0.

---

## Step 1 — Create an AdMob account

1. Go to **admob.google.com** and sign in with your Google account.
2. Accept the terms of service.
3. Set your **country** and **payment currency** (cannot be changed later).
4. Complete the account setup wizard.

---

## Step 2 — Add the Android app

1. In the AdMob dashboard click **Apps → Add app**.
2. Select **Android** as the platform.
3. Choose **"No, the app is not listed on a supported app store"** (until you publish it).
4. Enter the app name: `Tic Tac Toe`
5. Click **Add** — AdMob gives you an **App ID** that looks like:
   ```
   ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
   ```
6. Keep this page open — you need the App ID in Step 4.

---

## Step 3 — Create the three ad units

Still inside your Android app in AdMob:

### 3a — Banner

1. Click **Ad units → Add ad unit**.
2. Select **Banner**.
3. Name it `tictactoe-banner-android`.
4. Leave all other settings as default and click **Create ad unit**.
5. Copy the **Ad unit ID** (format `ca-app-pub-XXXX/XXXXXXXXXX`).

### 3b — Interstitial

1. Click **Add ad unit → Interstitial**.
2. Name it `tictactoe-interstitial-android`.
3. Click **Create ad unit** and copy the ID.

### 3c — Rewarded

1. Click **Add ad unit → Rewarded**.
2. Name it `tictactoe-rewarded-android`.
3. Set **Reward amount: 1**, **Reward item: hint** (or any label you like).
4. Click **Create ad unit** and copy the ID.

---

## Step 4 — Update Android code

### 4a — App ID in `AndroidManifest.xml`

Open `android/app/src/main/AndroidManifest.xml` and replace the test App ID:

```xml
<!-- BEFORE (test) -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>

<!-- AFTER (your real ID) -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

### 4b — Ad unit IDs in `lib/ads/ad_manager.dart`

Replace the three test unit IDs for Android:

```dart
// BEFORE
static String get _interstitialId =>
    defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-3940256099942544/1033173712'   // ← test
        : 'ca-app-pub-3940256099942544/4411468910';  // ← test (iOS)

static String get _rewardedId =>
    defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-3940256099942544/5224354917'   // ← test
        : 'ca-app-pub-3940256099942544/1712485313';  // ← test (iOS)

// AFTER — paste your real Android IDs; leave iOS placeholders for Step 6
static String get _interstitialId =>
    defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-XXXX/XXXXXXXXXX'   // your real Android interstitial
        : 'ca-app-pub-3940256099942544/4411468910';

static String get _rewardedId =>
    defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-XXXX/XXXXXXXXXX'   // your real Android rewarded
        : 'ca-app-pub-3940256099942544/1712485313';
```

### 4c — Banner ID in `lib/ui/game_screen.dart`

```dart
// BEFORE
static const String _bannerAdUnitId =
    'ca-app-pub-3940256099942544/6300978111';   // test

// AFTER
static const String _bannerAdUnitId =
    'ca-app-pub-XXXX/XXXXXXXXXX';   // your real Android banner
```

---

## Step 5 — iOS setup (when targeting iOS)

### 5a — Add the iOS app in AdMob

Repeat Step 2 selecting **iOS** as the platform. AdMob gives you a separate iOS App ID.

### 5b — Create iOS ad units

Repeat Step 3 for iOS. Name them `tictactoe-banner-ios`, etc. Copy the three iOS unit IDs.

### 5c — Add the iOS App ID to `ios/Runner/Info.plist`

Open `ios/Runner/Info.plist` and add inside the root `<dict>`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

### 5d — Update iOS unit IDs in `lib/ads/ad_manager.dart`

Replace the iOS sides of `_interstitialId` and `_rewardedId` with your real iOS unit IDs,
and update the iOS banner in `game_screen.dart` (currently the same constant is used for
both platforms — split into two constants if the IDs differ).

---

## Step 6 — Set up payment

1. In AdMob go to **Payments → Add payment method**.
2. Enter your bank account or PayPal details.
3. Verify your address when Google mails you a PIN (takes 2–4 weeks after your first earnings).
4. Minimum payout threshold: **$100** — Google pays monthly once you reach it.

---

## Step 7 — Verify before submitting to the Play Store

- [ ] Real App ID in `AndroidManifest.xml` (not the test one)
- [ ] Real ad unit IDs in `ad_manager.dart` and `game_screen.dart`
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all pass
- [ ] Tested on a real Android device (ads actually appear)
- [ ] You have NOT clicked your own ads during testing

---

## AdMob policies — know these before you publish

| Rule | Detail |
|---|---|
| **Never click your own ads** | Immediate account suspension |
| **No incentivised banner clicks** | Telling users to tap an ad is against policy |
| **Rewarded ads are fine** | Explicitly rewarding users for *watching* a video is allowed |
| **Interstitial timing** | Google enforces a 60-second cooldown between interstitials |
| **Revenue split** | Google keeps ~32 %; you receive ~68 % of ad revenue |
| **Payment threshold** | $100 minimum before Google pays out |
| **Review cycle** | Ads may show house ads (unpaid) for 24–48 h after going live |

---

## Quick reference — test IDs (current code)

These are safe to use during development. They never generate real revenue.

| Platform | Format | Test ID |
|---|---|---|
| Android | App ID | `ca-app-pub-3940256099942544~3347511713` |
| Android | Banner | `ca-app-pub-3940256099942544/6300978111` |
| Android | Interstitial | `ca-app-pub-3940256099942544/1033173712` |
| Android | Rewarded | `ca-app-pub-3940256099942544/5224354917` |
| iOS | App ID | `ca-app-pub-3940256099942544~1458002511` |
| iOS | Banner | `ca-app-pub-3940256099942544/2934735716` |
| iOS | Interstitial | `ca-app-pub-3940256099942544/4411468910` |
| iOS | Rewarded | `ca-app-pub-3940256099942544/1712485313` |
