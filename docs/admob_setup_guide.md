# AdMob Setup Guide — Tic Tac Toe

This guide walks you through replacing the Google **test** ad unit IDs with your real production
IDs before publishing the app. Complete every step in order.

> **Related files:** See [milestone_05_admob.md](milestone_05_admob.md) for the technical
> implementation details, [milestone_07_games_hub.md](milestone_07_games_hub.md) for the Games Hub
> (cross-promotion), and [CHANGELOG.md](../CHANGELOG.md) for what changed in each version.

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

## Step 3 — Create the two ad units

Still inside your Android app in AdMob. (Before the App Verse Games update the game also had a
banner; it no longer shows one, so no banner unit is needed.)

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

### 4b — Ad unit IDs in `lib/main.dart`

Since the App Verse Games update, ads run through `appverse_core_kit` (`kit.ads`). The game
only shows **interstitials** (between some games) and a **rewarded** video for a hint; there
is no banner any more. Pass your real IDs to the game's `CoreKitConfig`:

```dart
// BEFORE: the core kit's Google test IDs (AdUnitIds.test) are the default
const ticTacToeConfig = CoreKitConfig(
  gameId: 'tictactoe',
  gameName: 'Tic Tac Toe',
);

// AFTER
const ticTacToeConfig = CoreKitConfig(
  gameId: 'tictactoe',
  gameName: 'Tic Tac Toe',
  adUnitIds: AdUnitIds(
    androidInterstitial: 'ca-app-pub-XXXX/XXXXXXXXXX',
    androidRewarded: 'ca-app-pub-XXXX/XXXXXXXXXX',
    iosInterstitial: 'ca-app-pub-3940256099942544/4411468910', // test until Step 5
    iosRewarded: 'ca-app-pub-3940256099942544/1712485313', // test until Step 5
  ),
);
```

---

## Step 5 — iOS setup (when targeting iOS)

### 5a — Add the iOS app in AdMob

Repeat Step 2 selecting **iOS** as the platform. AdMob gives you a separate iOS App ID.

### 5b — Create iOS ad units

Repeat Step 3 for iOS. Name them `tictactoe-interstitial-ios` and `tictactoe-rewarded-ios`. Copy the two iOS unit IDs.

### 5c — Replace the iOS App ID in `ios/Runner/Info.plist`

`ios/Runner/Info.plist` already has Google's test App ID. Replace it with yours:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

### 5d — Update iOS unit IDs in `lib/main.dart`

Replace the `iosInterstitial` and `iosRewarded` test IDs in `ticTacToeConfig` with your real
iOS unit IDs.

---

## Step 6 — Set up payment

1. In AdMob go to **Payments → Add payment method**.
2. Enter your bank account or PayPal details.
3. Verify your address when Google mails you a PIN (takes 2–4 weeks after your first earnings).
4. Minimum payout threshold: **$100** — Google pays monthly once you reach it.

---

## Step 7 — Verify before submitting to the Play Store

- [ ] Real App ID in `AndroidManifest.xml` (not the test one)
- [ ] Real ad unit IDs in `ticTacToeConfig` (`lib/main.dart`)
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

## House Ads — free cross-promotion between your own apps

AdMob **House Ads** let you advertise your other games inside this app for free — no cost, no
revenue share. They fill unsold inventory and help you grow your portfolio without relying on
third-party advertisers.

### How it works

1. In the AdMob dashboard go to **Campaigns → Create campaign**.
2. Select **House ad** as the campaign type.
3. Upload a banner or interstitial creative promoting your next game (icon, tagline, Play Store link).
4. Set the campaign to run in `com.fullstackshack.tictactoe` ad units.
5. Set the eCPM floor to `$0.00` — house ads fill only when no paying ad wins the auction.

### Games Hub integration

The **Games Hub** bottom sheet (`lib/ui/games_sheet.dart`) already shows your other games
in-app at zero cost without AdMob. Use house ads as a complementary channel:

| Channel | When it shows | Cost |
|---|---|---|
| Games Hub sheet | User taps `sports_esports` icon or "More Games" button | Free, always visible |
| House ad (banner) | When banner ad auction has no paid winner | Free, AdMob-served |
| House ad (interstitial) | When interstitial slot has no paid winner | Free, AdMob-served |

### Tips
- Design house ad creatives at the same size as your real ads (320×50 for banner, full-screen for interstitial).
- Once your second game is on the Play Store, add its `playStoreId` to `games_catalog.dart` — the Games Hub card automatically shows a "Play" button that deep-links to it.
- House ads count toward your **AdMob impression metrics** but generate $0 revenue — they do not affect your account standing.

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
