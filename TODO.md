# Google Play Store Publication Checklist

**Owner:** FullStackShack  
**Package prefix:** `com.fullstackshack.<appname>`  
**Contact:** michaelkuen888@gmail.com  
**Last updated:** 2026-07-20

A replicable, end-to-end checklist for publishing any Flutter app from the FullStackShack
ecosystem to the Google Play Store, with Google AdMob ads enabled.

Work through every section in order. Items marked **(once per account)** only need doing the
first time you publish — skip them for subsequent apps.

---

## Part 1 — Google Account & Developer Identity (once per account)

- [ ] Decide which Google account will be the "FullStackShack" publisher identity
  - Recommended: a dedicated account (not a personal Gmail) — e.g. `hello@fullstackshack.com`
  - This account links Play Console, AdMob, Google Analytics, and Firebase together
- [ ] Enable **2-Step Verification** on that account (Play Console requires it)
- [ ] Save the account email and recovery codes in a password manager

---

## Part 2 — Google Play Console Registration (once per account)

- [ ] Go to **play.google.com/console** and sign in with the FullStackShack Google account
- [ ] Click **Get started** and choose your account type:
  - **Personal:** suitable for a solo developer; your full legal name becomes public
  - **Organisation:** use if you have a registered business name
- [ ] Pay the **one-time $25 USD** developer registration fee (credit/debit card)
- [ ] Complete the developer profile:
  - Developer name (shown publicly on Play Store): `FullStackShack`
  - Contact email: `michaelkuen888@gmail.com`
  - Phone number (for account verification)
  - Physical address (required by Google; not shown to users)
- [ ] Accept the **Google Play Developer Distribution Agreement**
- [ ] Wait for account activation (usually instant; sometimes up to 48 hours)
- [ ] Set up the **Payments profile** (required to receive earnings from paid apps or in-app purchases):
  - Play Console → **Setup → Payments profile**
  - Enter legal name, address, and bank account for payouts
  - Complete tax information if prompted (Google withholds tax in some regions)

---

## Part 3 — Google AdMob Account Setup (once per account)

- [ ] Go to **admob.google.com** and sign in with the same FullStackShack Google account
- [ ] Accept the AdMob Terms of Service
- [ ] Set your **country** and **payment currency** — these **cannot be changed later**
- [ ] Complete the account setup wizard
- [ ] Go to **Payments → Payment methods** and add your bank account or PayPal:
  - Google will mail a **PIN to your physical address** to verify — allow 2–4 weeks
  - **Minimum payout threshold: $100 USD** — Google pays out monthly once reached
  - Revenue share: Google keeps ~32%; you receive ~68% of gross ad revenue

---

## Part 4 — Privacy Policy Hosting (once per account; update content per app)

A publicly accessible privacy policy is **required** by Google Play for any app that uses
AdMob, collects user data, or targets users in regions with privacy laws (GDPR, CCPA, etc.).
A single policy page can cover every app in the ecosystem.

- [ ] Create a **GitHub repository** named `fullstackshack.github.io`
  - If it already exists, skip this step
- [ ] Enable **GitHub Pages**: Settings → Pages → Source: branch `main`, folder: `/ (root)`
- [ ] Create a `privacy-policy.html` at the root of that repo. The policy must cover:
  - Identity of the developer/publisher
  - What data is collected (AdMob collects the device Advertising ID / IDFA)
  - How data is used (ad personalisation, analytics, fraud prevention)
  - Third-party services: **Google AdMob** (link to Google's privacy policy)
  - Data retention and deletion
  - Contact email for privacy enquiries: `michaelkuen888@gmail.com`
  - Effective date
- [ ] Confirm the policy is publicly reachable at:
  `https://fullstackshack.github.io/privacy-policy`
- [ ] Save that URL — you will paste it into every Play Store listing and AdMob app entry

> **Per-app note:** If an app collects data beyond what AdMob collects (e.g. user accounts,
> location, camera), update the policy to name the extra data before submitting that app.

---

## Part 5 — App-Specific AdMob Setup (per app)

### 5A — Register the app in AdMob

- [ ] In the AdMob dashboard click **Apps → Add app**
- [ ] Select **Android** as the platform
- [ ] Choose **"No, the app is not listed on a supported app store"** (until after first publish)
- [ ] Enter the app name (e.g. `Tic Tac Toe`)
- [ ] Copy the **App ID** — format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`
  - Paste it somewhere safe; you need it in step 5D and after publishing

### 5B — Create the three Android ad units

Inside the AdMob app you just created:

- [ ] **Banner** → Add ad unit → Banner
  - Name: `<appname>-banner-android`
  - Leave all settings as default
  - Copy the **Ad unit ID** (`ca-app-pub-XXXX/XXXXXXXXXX`)
- [ ] **Interstitial** → Add ad unit → Interstitial
  - Name: `<appname>-interstitial-android`
  - Copy the Ad unit ID
- [ ] **Rewarded** → Add ad unit → Rewarded
  - Name: `<appname>-rewarded-android`
  - Reward amount: `1` / Reward item: `hint`
  - Copy the Ad unit ID

### 5C — Link privacy policy to the AdMob app entry

- [ ] In AdMob → Apps → select the app → **App settings**
- [ ] Paste your privacy policy URL

### 5D — Replace test IDs in the Flutter project

> See `docs/admob_setup_guide.md` for the exact lines. Summary:

- [ ] `android/app/src/main/AndroidManifest.xml`
  — replace the `com.google.android.gms.ads.APPLICATION_ID` value with your real AdMob App ID

- [ ] `lib/ads/ad_manager.dart`
  — replace the three Android test unit IDs (interstitial, rewarded, banner) with real IDs

- [ ] `lib/ui/game_screen.dart`
  — replace `_bannerAdUnitId` test value with your real Android banner unit ID

- [ ] Run `flutter analyze` and `flutter test` — both must pass with zero issues

> **Policy reminder:** Never click your own ads — AdMob will suspend your account.

### 5E — House Ads for cross-promotion (optional; set up after second app is live)

- [ ] In AdMob go to **Campaigns → Create campaign → House ad**
- [ ] Upload a banner creative (320×50 px) promoting your next game
- [ ] Upload a full-screen interstitial creative
- [ ] Set eCPM floor to `$0.00` — house ads fill only unsold inventory (free)
- [ ] Target the campaign to this app's ad units
- [ ] Once your next game is on the Play Store, add its Play Store ID to `games_catalog.dart`
  so the Games Hub card shows a live "Play" button

---

## Part 6 — Keystore & App Signing (once per account; reuse the same keystore for all apps)

The upload keystore signs every app you publish. **If you lose it you cannot push updates.**

### Generate the keystore (do this once)

```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

When prompted:
- Keystore password — choose something strong
- Key password — can be the same as the keystore password
- First and last name: `FullStackShack`
- Organisation: `FullStackShack`
- City, State, Country code

- [ ] `upload-keystore.jks` generated in your home directory
- [ ] Back up `upload-keystore.jks` to a **password manager or encrypted cloud storage** — do this now, before you forget
- [ ] Record the keystore password and alias in the same secure location

### Wire signing into the build (per app)

- [ ] Create `android/key.properties` — **this file must never be committed to git**:
  ```properties
  storePassword=<your keystore password>
  keyPassword=<your key password>
  keyAlias=upload
  storeFile=<absolute path to upload-keystore.jks>
  ```
  Example storeFile on Windows: `C:/Users/Admin/upload-keystore.jks`

- [ ] Confirm `android/key.properties` is in `.gitignore` (check the file)

- [ ] Edit `android/app/build.gradle` to load `key.properties` and configure `signingConfigs.release`:
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

- [ ] Verify signing works:
  ```bash
  flutter build apk --release
  ```
  The command must complete without errors and produce `build/app/outputs/flutter-apk/app-release.apk`

---

## Part 7 — App Version & Build Config (per release)

- [ ] Open `pubspec.yaml` and set the version:
  ```yaml
  version: 1.0.0+1
  ```
  Format is `<semantic-version>+<build-number>`. The **build number must increment** with every
  upload to the Play Store — Play Console will reject a duplicate build number.

- [ ] Confirm `applicationId` in `android/app/build.gradle` matches:
  `com.fullstackshack.<appname>`

- [ ] Confirm `minSdkVersion` is set to `flutter.minSdkVersion` (or at minimum API 21)

- [ ] Confirm `targetSdkVersion` and `compileSdkVersion` match the current Flutter-recommended
  Android API level (check `flutter doctor` output and Flutter release notes)

---

## Part 8 — Play Store Assets (per app)

Prepare these before opening the Play Console submission form.

### Text content

- [ ] **App title** (max 30 characters): e.g. `Tic Tac Toe`
- [ ] **Short description** (max 80 characters):
  e.g. `Classic Tic Tac Toe — AI opponent, 3 difficulty levels, health reminders`
- [ ] **Full description** (max 4000 characters) — include:
  - What the game is and how to play
  - Key features with bullet points (AI difficulty levels, vs-friend mode, health timer, etc.)
  - Free to play, no sign-in required
  - Privacy statement (e.g. "No personal data stored")
  - Keywords woven in naturally (tic tac toe, noughts and crosses, strategy, two player, puzzle)
- [ ] **Release notes / What's new** (shown on each release): e.g. `Initial release`

### Graphic assets

| Asset | Required dimensions | Notes |
|---|---|---|
| App icon | 512×512 px | PNG, 32-bit RGBA, no transparency (transparency is cropped) |
| Feature graphic | 1024×500 px | PNG or JPEG — shown at top of listing page |
| Phone screenshots | min 1080×1920 px portrait | Minimum 2, maximum 8 |
| 7-inch tablet screenshots | min 1200×1920 px | Optional but recommended |
| 10-inch tablet screenshots | min 1600×2560 px | Optional |
| Promo video | YouTube URL | Optional, 30–120 seconds |

- [ ] App icon ready (1024×1024 source; Play Console accepts 512×512 PNG)
- [ ] Feature graphic designed (recommended: use app's colour scheme)
- [ ] At least 4 phone screenshots captured from a real device in **release mode**
  - Suggested screens for this app:
    - Home/start screen with health bar visible
    - Mid-game board with moves placed
    - Win state with highlighted winning row
    - Difficulty selector panel
    - Games Hub bottom sheet
  - Capture with: `adb exec-out screencap -p > screenshot.png`

---

## Part 9 — Create the Play Store Listing (per app)

- [ ] Sign in to **play.google.com/console**
- [ ] Click **Create app**
  - App name: `Tic Tac Toe`
  - Default language: `English (United States)`
  - App or Game: **Game**
  - Free or Paid: **Free**
  - Accept all declarations (content guidelines, US export laws)
- [ ] Click **Create app** — you land on the app Dashboard

### Main store listing

Under **Grow → Store presence → Main store listing**:

- [ ] Short description
- [ ] Full description
- [ ] App icon (512×512 PNG)
- [ ] Feature graphic (1024×500 PNG or JPEG)
- [ ] Phone screenshots (at least 2)
- [ ] Tablet screenshots (optional)
- [ ] Save

### Store settings

- [ ] App category: **Games → Casual** (or Board / Puzzle)
- [ ] Tags: add relevant terms
- [ ] Contact email: `michaelkuen888@gmail.com`
- [ ] Privacy policy URL: `https://fullstackshack.github.io/privacy-policy`
- [ ] Save

---

## Part 10 — Content Rating (per app)

Under **Policy → App content → Content ratings**:

- [ ] Click **Start questionnaire**
- [ ] Select category: **Games (other)**
- [ ] Answer all questions honestly. For a standard FullStackShack game with AdMob:

  | Question | Answer |
  |---|---|
  | Violence | None |
  | Sexual content | None |
  | Language | None |
  | Controlled substances | None |
  | User-generated content | No |
  | Location sharing | No |
  | Ads targeted at children | No |

- [ ] Submit — expected rating: **Everyone (E)** / **PEGI 3**
- [ ] Click **Apply rating**

---

## Part 11 — Data Safety Section (per app)

Required since Android 12 (API 32). The app will be rejected without a completed Data Safety form.

Under **Policy → App content → Data safety**:

- [ ] Does your app collect or share user data? **Yes** (AdMob does)
- [ ] Data type collected: **Device or other IDs → Advertising ID**
  - Purpose: **Advertising or marketing**
  - Is the data shared with third parties? **Yes** (Google AdMob)
  - Is the data encrypted in transit? **Yes**
  - Can users request deletion? **No** (no account, no stored personal data in this app)
- [ ] Confirm no other data types are collected (no name, email, location, photos, etc.)
- [ ] Enter privacy policy URL: `https://fullstackshack.github.io/privacy-policy`
- [ ] Save and submit

---

## Part 12 — Build the Release App Bundle (per release)

App Bundle (AAB) is **required** for all new apps submitted to the Play Store.

- [ ] Confirm all test AdMob IDs have been replaced with real IDs (Part 5D)
- [ ] Run quality gates:
  ```bash
  flutter analyze
  flutter test
  ```
  Both must pass with **zero issues** before proceeding.

- [ ] Build the signed App Bundle:
  ```bash
  flutter build appbundle --release
  ```
  Output: `build/app/outputs/bundle/release/app-release.aab`

- [ ] Also build a release APK for device testing:
  ```bash
  flutter build apk --release
  ```

- [ ] Install and test on a **real Android device**:
  ```bash
  adb install build/app/outputs/flutter-apk/app-release.apk
  ```

- [ ] On the real device, verify all features:
  - [ ] App launches and loads correctly
  - [ ] Banner ad appears at bottom of game screen
  - [ ] Interstitial ad appears after the correct number of completed games
  - [ ] Rewarded ad plays when requesting a hint
  - [ ] Privacy policy screen opens and shows correct text
  - [ ] Score tracking persists across app restarts
  - [ ] Health timer displays and triggers break reminders
  - [ ] Games Hub sheet opens and all buttons work
  - [ ] Dark mode and light mode both render correctly
  - [ ] AI plays at all three difficulty levels
  - [ ] Two-player mode works correctly
  - [ ] No visual glitches or layout overflows
  - [ ] **Do NOT tap your own ads**

---

## Part 13 — Internal Testing Track (recommended before production)

- [ ] In Play Console go to **Testing → Internal testing → Create new release**
- [ ] Upload `app-release.aab`
- [ ] Enter release name (e.g. `1.0.0 (1)`) and release notes
- [ ] Click **Save** then **Review release** — fix any warnings
- [ ] Click **Start rollout to Internal testing**
- [ ] Go to the **Testers** tab and add your own Google account
- [ ] On an Android device, open the opt-in URL sent to your tester email and install the app from Play Store
- [ ] Run the same verification checklist as Part 12 on the Play Store build

---

## Part 14 — Production Release

Once internal testing passes with no issues:

- [ ] In Play Console go to **Production → Releases → Create new release**
- [ ] Upload `app-release.aab` (or promote the internal testing release)
- [ ] Enter release notes (What's new) — for initial release, list key features
- [ ] Set rollout percentage:
  - **100%** — simplest for a first release
  - **20%** — cautious rollout; can increase or halt if issues appear
- [ ] Click **Review release** — address any errors or critical warnings
- [ ] Click **Start rollout to Production**
- [ ] First submission review: typically **3–7 business days**
- [ ] Subsequent updates: typically **hours to 2 days**

---

## Part 15 — Post-Publication

### Immediately after going live

- [ ] Confirm the app appears on the Play Store (search by name or package)
- [ ] In AdMob → Apps → select the app → **Link to Play Store listing**
  - Linking unlocks audience-based targeting and typically increases eCPM
- [ ] Update `games_catalog.dart` — set `playStoreId` to the real Play Store app ID
  - Find the ID in the Play Store URL: `play.google.com/store/apps/details?id=com.fullstackshack.tictactoe`

### Ongoing monitoring

- [ ] **Android Vitals** (Play Console → Android Vitals): watch crash rate and ANR rate
  - Google may throttle distribution if crash rate is above ~1.09%
- [ ] **AdMob dashboard**: monitor impressions, fill rate, eCPM, estimated earnings
  - Expect house ads (unpaid) for the first 24–48 hours while the system warms up
- [ ] **Play Console Reviews**: respond to early user reviews — impacts ranking algorithm
- [ ] **Play Console Ratings**: monitor star rating; fix bugs causing negative reviews promptly

### Optional revenue enhancements (add as future milestones)

- [ ] **AdMob mediation** — lets AdMob auction against Meta Audience Network, AppLovin,
  Unity Ads, etc. Typically increases eCPM by 20–50%. Requires adding partner SDKs.
- [ ] **User Messaging Platform (UMP)** — shows a GDPR/CCPA consent dialog before loading
  ads. Required if you target EU or California users and want personalised ads.
  Flutter package: `google_mobile_ads` includes UMP support.
- [ ] **App Open Ads** — shown on app launch/resume. High eCPM. Add as a separate milestone.
- [ ] **Firebase Analytics** — understand user retention, session length, drop-off points.

---

## Part 16 — Replication Guide for the Next App

When publishing the **next** FullStackShack app, skip Parts 1–4 (already done) and start
from Part 5. This table shows what changes per app vs what you reuse:

| Item | Per account (reuse) | Per app (redo) |
|---|---|---|
| Google / Play Console account | Reuse | — |
| AdMob account | Reuse | Add a new app entry in AdMob |
| Privacy policy URL | Reuse same URL | Update policy text if new data collected |
| Upload keystore file | Reuse `upload-keystore.jks` | — |
| `key.properties` | Reuse same file path | Update `storeFile` path if moved |
| Package name in `build.gradle` | — | `com.fullstackshack.<newappname>` |
| AdMob App ID | — | New entry → new App ID |
| Ad unit IDs (banner, int., rewarded) | — | Create 3 new units per app |
| `pubspec.yaml` version | — | Start at `1.0.0+1` |
| App icon / feature graphic / screenshots | — | Unique per app |
| Play Store listing text | — | Unique per app |
| Content rating questionnaire | — | Complete per app |
| Data safety form | — | Complete per app |
| Build number | — | Must increment with every upload |

---

## Quick Reference — Key Files to Update Before Each Release

| File | What to update |
|---|---|
| `pubspec.yaml` | `version:` — increment build number every upload |
| `lib/ads/ad_manager.dart` | Replace 3 test ad unit IDs with real ones |
| `lib/ui/game_screen.dart` | Replace `_bannerAdUnitId` test ID |
| `android/app/src/main/AndroidManifest.xml` | Replace AdMob App ID in meta-data |
| `android/key.properties` | Create with keystore path + passwords (never commit) |
| `android/app/build.gradle` | Add `signingConfigs.release` block |
| `lib/games/games_catalog.dart` | Set real `playStoreId` after app is live |

---

## Quick Reference — Key URLs

| Resource | URL |
|---|---|
| Google Play Console | play.google.com/console |
| Google AdMob | admob.google.com |
| Privacy policy | https://fullstackshack.github.io/privacy-policy |
| Flutter Android deployment docs | docs.flutter.dev/deployment/android |
| AdMob test IDs & code locations | `docs/admob_setup_guide.md` |

---

## Milestone Status (this app)

| # | Milestone | Status |
|---|-----------|--------|
| 00 | Project scaffold, docs, copyright, git | ✅ Done |
| 01 | Core game logic | ✅ Done |
| 02 | Basic UI | ✅ Done |
| 03 | Win/draw detection | ✅ Done |
| 04 | Minimax AI opponent | ✅ Done |
| 05 | Google AdMob integration | ✅ Done |
| 06 | Animations, sound, theming | ✅ Done |
| 07 | Games Hub | ✅ Done |
| 08 | AI difficulty levels + release prep | ✅ Done |
| 09 | Custom app icon + splash screen | ✅ Done |
| 10 | Health awareness session timer | ✅ Done |
| 11 | Persistent score tracking | ✅ Done |
| 12 | In-app privacy policy | ✅ Done |
| — | **Google Play publication** | ⬜ In progress |
