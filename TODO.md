# Tic Tac Toe — Full Release To-Do List

**App:** com.fullstackshack.tictactoe  
**Owner:** FullStackShack  
**Last updated:** 2026-07-01

This checklist covers everything from first Google account registration through
to a live production release on the Google Play Store.

---

## ✅ Development — Completed Milestones

| # | Milestone | Status |
|---|-----------|--------|
| 00 | Project scaffold, docs, copyright, git | ✅ Done |
| 01 | Core game logic (board, moves, players) | ✅ Done |
| 02 | Basic UI (grid, X/O rendering, tap to play) | ✅ Done |
| 03 | Win / draw detection, end-game UI | ✅ Done |
| 04 | Minimax AI opponent, vs AI / vs Human toggle, difficulty | ✅ Done |
| 05 | Google AdMob integration (banner, interstitial, rewarded) | ✅ Done |
| 06 | Animations, sound, theming (light / dark mode) | ✅ Done |
| 07 | Games Hub bottom sheet + Play Store deep links | ✅ Done |
| 08 | AI difficulty levels (Easy / Medium / Hard) | ✅ Done |
| 09 | Custom app icon + native splash screen | ✅ Done |
| 10 | Health awareness session timer + break reminders | ✅ Done |

---

## 1 — Google Account Setup

- [ ] **Create a Google account** (or confirm existing one to use for all Google services)
- [ ] Ensure 2-Step Verification is enabled on the account
- [ ] Note the account email — this will be the developer identity for Play Console and AdMob

---

## 2 — Google Play Console Registration

- [ ] Go to [play.google.com/console](https://play.google.com/console) and sign in
- [ ] Click **Get Started** and choose **Personal** or **Organisation** account type
- [ ] Pay the **one-time $25 USD registration fee** (credit/debit card)
- [ ] Complete the developer profile:
  - Developer name (public — shown to users): `FullStackShack`
  - Contact email address
  - Phone number (for verification)
  - Physical address (required — not shown publicly)
- [ ] Accept the **Google Play Developer Distribution Agreement**
- [ ] Wait for account verification (usually instant, sometimes up to 48 h)

---

## 3 — Google AdMob Account Setup

> The app already has Google **test** ad unit IDs in the code. These must be replaced
> with real IDs before submitting to the Play Store.

- [ ] Go to [admob.google.com](https://admob.google.com) and sign in with the same Google account
- [ ] Complete AdMob account setup:
  - Country / timezone
  - Payment information (bank account or payment method for earnings)
  - Accept AdMob Terms of Service
- [ ] Click **Add App** → select **Android** → enter app name "Tic Tac Toe"
  - If the app is not yet published, choose "No" for "Is the app listed on a supported app store?"
  - After publishing, return and link the Play Store listing
- [ ] Note the **AdMob App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)

### Create Ad Units

- [ ] **Banner ad unit** — click Add Ad Unit → Banner
  - Name: `tic_tac_toe_banner`
  - Note the ad unit ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)
- [ ] **Interstitial ad unit** — Add Ad Unit → Interstitial
  - Name: `tic_tac_toe_interstitial`
  - Note the ad unit ID
- [ ] **Rewarded ad unit** — Add Ad Unit → Rewarded
  - Name: `tic_tac_toe_rewarded`
  - Note the ad unit ID

### Replace Test IDs in Code

- [ ] Open `lib/ads/ad_manager.dart` — replace all three test IDs with real ones
- [ ] Open `lib/ui/game_screen.dart` — replace the `_bannerAdUnitId` test ID
- [ ] Open `android/app/src/main/AndroidManifest.xml` — replace the `com.google.android.gms.ads.APPLICATION_ID` meta-data value with your real AdMob App ID

> ⚠️ See `docs/admob_setup_guide.md` for the exact lines to change.  
> ⚠️ **Never click your own ads** — AdMob will suspend the account.

---

## 4 — App Signing (Keystore)

Android release builds must be signed. Google Play uses **upload keys**.

### Generate the upload keystore

```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

You will be prompted for:
- Keystore password (choose something strong, store it safely)
- Key alias password (can be the same)
- Name, organisation, city, country

- [ ] Generate keystore and store `upload-keystore.jks` somewhere **outside** the project directory
- [ ] Back up the keystore file to a secure location (cloud drive, password manager) — **losing it means you can never update the app**
- [ ] Record passwords in a password manager

### Wire keystore into the build

- [ ] Create `android/key.properties` (this file must NOT be committed):
  ```properties
  storePassword=<your-keystore-password>
  keyPassword=<your-key-password>
  keyAlias=upload
  storeFile=<absolute-path-to>/upload-keystore.jks
  ```
- [ ] Verify `android/key.properties` is listed in `.gitignore` (it should already be)
- [ ] Edit `android/app/build.gradle` to load `key.properties` and configure `signingConfigs.release`
  ```groovy
  def keystoreProperties = new Properties()
  def keystorePropertiesFile = rootProject.file('key.properties')
  if (keystorePropertiesFile.exists()) {
      keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
  }

  android {
      signingConfigs {
          release {
              keyAlias keystoreProperties['keyAlias']
              keyPassword keystoreProperties['keyPassword']
              storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
              storePassword keystoreProperties['storePassword']
          }
      }
      buildTypes {
          release {
              signingConfig signingConfigs.release
          }
      }
  }
  ```
- [ ] Build a signed release to verify it works:
  ```bash
  flutter build appbundle --release
  ```
  Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 5 — Privacy Policy

AdMob collects and processes user data (Advertising ID). Google Play requires a privacy
policy for any app that uses AdMob or collects user data.

- [ ] Write a privacy policy that covers:
  - What data is collected (Advertising ID via AdMob)
  - How it is used (personalised / non-personalised ads)
  - Third parties (Google AdMob — link to Google's privacy policy)
  - Contact information for privacy enquiries
  - No personal data is otherwise stored by the app
- [ ] Host the privacy policy at a public URL. Options:
  - GitHub Pages (free): create a `privacy-policy.html` in a GitHub repo with Pages enabled
  - Google Sites (free)
  - Notion public page
  - Simple hosting (Netlify, Vercel)
- [ ] Note the public URL (e.g. `https://fullstackshack.github.io/privacy/tic-tac-toe`)
- [ ] Add a privacy policy link inside the app (e.g. in an About dialog or settings)
- [ ] Add the privacy policy URL to the Play Console store listing

---

## 6 — Play Store Listing Assets

Prepare all assets before starting the Play Console submission form.

### Text

- [ ] **App name:** `Tic Tac Toe` (max 30 chars)
- [ ] **Short description** (max 80 chars):
  `Classic Tic Tac Toe with AI opponent, difficulty levels and health reminders.`
- [ ] **Full description** (max 4000 chars) — cover: gameplay, AI modes, health timer, no personal data

### Graphics

- [ ] **App icon** — already generated at `assets/icon/app_icon.png` (1024×1024 PNG, no alpha)
- [ ] **Feature graphic** — 1024×500 PNG (banner shown at top of Play Store listing)
  - Design in Canva, Figma, or any image editor
  - Use the app's dark navy colour scheme (`#1A1A2E`)
- [ ] **Phone screenshots** — minimum 2, recommended 4–8
  - Capture from a real Android device or emulator in release mode
  - Recommended sizes: 1080×1920 (portrait) or 1080×2400 (tall phones)
  - Suggested screens to capture:
    - [ ] Home / start screen (health bar visible, vs AI mode)
    - [ ] Mid-game board with X and O placed
    - [ ] Win state with highlighted winning line
    - [ ] AI difficulty selection
    - [ ] Games Hub bottom sheet (More Games)
    - [ ] Dark mode vs light mode comparison
- [ ] **7-inch tablet screenshots** (optional but recommended)
- [ ] **10-inch tablet screenshots** (optional)

---

## 7 — Play Console: Create the App

- [ ] Sign in to [play.google.com/console](https://play.google.com/console)
- [ ] Click **Create app**
- [ ] Fill in:
  - App name: `Tic Tac Toe`
  - Default language: `English (United Kingdom)` or `English (United States)`
  - App or game: **Game**
  - Free or paid: **Free**
- [ ] Accept the Declarations (content guidelines, US export laws)
- [ ] Click **Create app**

---

## 8 — Play Console: Complete Store Listing

Under **Grow → Store presence → Main store listing**:

- [ ] Add short description
- [ ] Add full description
- [ ] Upload app icon (512×512 PNG — Play Console will resize from your 1024×1024)
- [ ] Upload feature graphic
- [ ] Upload phone screenshots (at least 2)
- [ ] Upload tablet screenshots (optional)
- [ ] Set **App category**: Games → Casual
- [ ] Add **Tags** (e.g. puzzle, board game, strategy, two-player)
- [ ] Add **Contact details** (email address)
- [ ] Add **Privacy policy URL**
- [ ] Save

---

## 9 — Play Console: Content Rating

Under **Policy → App content → Content rating**:

- [ ] Click **Start questionnaire**
- [ ] Category: **Games (other)**
- [ ] Answer all questions honestly — Tic Tac Toe has:
  - No violence
  - No sexual content
  - No user-generated content
  - No location sharing
  - No ads targeted at children (AdMob handles this)
- [ ] Submit — expected rating: **Everyone (E)** / **PEGI 3**
- [ ] Apply the rating

---

## 10 — Play Console: Data Safety

Under **Policy → App content → Data safety**:

- [ ] Declare that the app **collects data** (via AdMob):
  - **Device or other identifiers** — Advertising ID
  - Purpose: Advertising or marketing
  - Shared with third parties: Yes (Google AdMob)
  - Required (users cannot opt out of AdMob without opting out of all ads)
- [ ] Declare that the app does **not** collect:
  - Name, email, phone, location, photos, contacts, etc.
- [ ] Confirm the privacy policy URL is entered
- [ ] Save and submit

---

## 11 — Release Build

- [ ] Replace all test ad unit IDs (see Section 3) before this step
- [ ] Run quality gates:
  ```bash
  flutter analyze    # must report: No issues found
  flutter test       # must report: All tests passed
  ```
- [ ] Build the signed App Bundle:
  ```bash
  flutter build appbundle --release
  ```
- [ ] Locate the output: `build/app/outputs/bundle/release/app-release.aab`
- [ ] Check file size — typical range 10–30 MB for this app

---

## 12 — Internal Testing (Recommended First Step)

Before going to production, test via the Internal Testing track.

- [ ] In Play Console: **Testing → Internal testing → Create new release**
- [ ] Upload `app-release.aab`
- [ ] Enter release name and release notes
- [ ] Save and roll out to **Internal testing** (100%)
- [ ] Add testers: go to **Testers** tab, add your Google account email
- [ ] On an Android device, accept the tester invite link and install the app
- [ ] Verify on a real device:
  - [ ] App installs and launches
  - [ ] AdMob ads load (real ads, not test ads — use a new device or clear advertising ID)
  - [ ] Health timer works correctly
  - [ ] AI plays at all difficulty levels
  - [ ] Game Hub sheet opens with correct Play Store links
  - [ ] Dark / light theme toggle works
  - [ ] No crashes in Android Vitals after a few play sessions

---

## 13 — Production Release

Once internal testing passes:

- [ ] In Play Console: **Production → Create new release**
- [ ] Promote from Internal Testing or upload the same AAB
- [ ] Write release notes (what's new — first release: mention all key features)
- [ ] Set rollout percentage (start at 20% if cautious, or 100%)
- [ ] Click **Review release** — fix any warnings
- [ ] Click **Start rollout to Production**
- [ ] Google review typically takes **1–3 days** for first submission

---

## 14 — After Going Live

- [ ] Confirm the app appears on the Play Store (search "Tic Tac Toe FullStackShack")
- [ ] Update the `games_catalog.dart` `playStoreId` with the real app ID from the Play Store URL
- [ ] Return to AdMob → link the app to the Play Store listing
- [ ] Set up AdMob payment threshold and payment method

### Ongoing

- [ ] Monitor **Android Vitals** in Play Console for crashes and ANRs
- [ ] Monitor **AdMob dashboard** for impressions, eCPM, estimated earnings
- [ ] Respond to user reviews in Play Console
- [ ] Address any policy warnings from Google Play
- [ ] Plan future updates (score tracking, more games, more AI personalities)

---

## Deferred Enhancements (Planned)

| Option | Description | Status |
|--------|-------------|--------|
| B | Score tracking — win/loss/draw counters persisted with SharedPreferences | ⏸ Deferred |
| C | In-app privacy policy page (required for Play Store + AdMob) | ⏸ Deferred |

---

## Quick Reference — Key Files to Update Before Release

| File | What to change |
|------|---------------|
| `lib/ads/ad_manager.dart` | Replace 3 test ad unit IDs with real ones |
| `lib/ui/game_screen.dart` | Replace `_bannerAdUnitId` test ID |
| `android/app/src/main/AndroidManifest.xml` | Replace AdMob App ID meta-data value |
| `android/key.properties` | Create with keystore path + passwords (do NOT commit) |
| `android/app/build.gradle` | Add `signingConfigs.release` block |
| `lib/games/games_catalog.dart` | Add real `playStoreId` once app is live |

---

*See `docs/admob_setup_guide.md` for detailed AdMob ID replacement instructions.*
