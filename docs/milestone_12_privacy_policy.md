# Milestone 12 — Privacy Policy

**Date:** 2026-07-01
**Branch:** milestone/12-privacy-policy
**Status:** ✅ Complete

## Objectives

- [x] Two-tab in-app privacy policy screen (Summary + Full Policy)
- [x] Summary: six illustrated cards covering the key topics at a glance
- [x] Full Policy: complete legal text covering GDPR, CCPA, and COPPA requirements
- [x] Privacy policy accessible from AppBar icon on the main screen
- [x] Privacy policy link in the Games Hub footer
- [x] Contact button that opens the user's mail app
- [x] `flutter analyze` — zero issues
- [x] `flutter test` — 98 tests, all pass

## New File

### `lib/ui/privacy_policy_screen.dart`

Opened via `PrivacyPolicyScreen.show(context)` — pushes a full-screen route.

#### Summary Tab

Six `_SummaryItem` cards, each with a coloured icon bubble, bold heading, and 2–3
sentence plain-English description:

| Card | Icon colour | Topic |
|------|-------------|-------|
| What We Collect | Blue `#40C4FF` | No personal data collected directly |
| Ads & Advertising ID | Amber `#FFD740` | AdMob may use Advertising ID |
| Data Stays on Device | Green `#69F0AE` | Scores in SharedPreferences only |
| Children's Privacy | Red `#FF5252` | Not directed at under-13s |
| Your Controls | Purple `#CE93D8` | Opt-out via Android Ads settings |
| Contact Us | Pink `#F48FB1` | michaelkuen888@gmail.com |

An `_EffectiveDateBanner` at the top shows effective date, app name, and developer.

#### Full Policy Tab

Eight numbered `_PolicySection` entries (several with `_PolicySubSection` children):

| # | Section |
|---|---------|
| — | Header (effective date, app ID) |
| 1 | Information We Collect (1.1 AdMob · 1.2 Local Storage · 1.3 Session Timer · 1.4 Not Collected) |
| 2 | How We Use Your Information |
| 3 | Third-Party Services (3.1 Google AdMob) |
| 4 | Data Retention and Security |
| 5 | Children's Privacy (COPPA) |
| 6 | Your Privacy Rights (6.1 General · 6.2 GDPR · 6.3 CCPA) |
| 7 | Changes to This Policy |
| 8 | Contact Us + "Send us an email" OutlinedButton (mailto:) |

## Entry Points

| Location | Widget | Action |
|----------|--------|--------|
| Main screen AppBar | `IconButton(Icons.privacy_tip_outlined)` | `PrivacyPolicyScreen.show(context)` |
| Games Hub footer | `GestureDetector` underlined text | `PrivacyPolicyScreen.show(context)` |

## Play Store Requirement

The privacy policy URL entered in Google Play Console should link to a hosted version
of this same content. Quickest option: a GitHub Pages page at
`https://fullstackshack.github.io/privacy/tic-tac-toe` that mirrors the Full Policy text.

See `TODO.md` Section 5 for the full hosting checklist.
