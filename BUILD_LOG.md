# Build Log

All commands run during development, with exact output. Nothing summarised.

---

## Milestone 00 — Project Setup

**Date:** 2026-06-11  
**Flutter:** 3.41.4 (channel stable)  
**Dart:** 3.11.1  
**DevTools:** 2.54.1  

---

### flutter --version

```
Flutter 3.41.4 • channel stable • https://github.com/flutter/flutter.git
Framework • revision ff37bef603 (3 months ago) • 2026-03-03 16:03:22 -0800
Engine • hash 99578ad0355da00edb26301c874a3c250a5716f5 (revision e4b8dca3f1) (3 months ago) • 2026-03-03 18:24:54.000Z
Tools • Dart 3.11.1 • DevTools 2.54.1
```

---

### Bundle ID update

Updated `com.example.tictactoe` → `com.fullstackshack.tictactoe` across:
- `android/app/build.gradle.kts` (namespace + applicationId)
- `android/app/src/main/kotlin/com/fullstackshack/tictactoe/MainActivity.kt` (package; directory restructured)
- `linux/CMakeLists.txt`
- `ios/Runner.xcodeproj/project.pbxproj` (all occurrences)
- `macos/Runner.xcodeproj/project.pbxproj` (all occurrences)
- `macos/Runner/Configs/AppInfo.xcconfig`
- `windows/runner/Runner.rc` (CompanyName + LegalCopyright)

---

### flutter analyze

```
Resolving dependencies...
Downloading packages...
  matcher 0.12.19 (0.12.20 available)
  meta 1.17.0 (1.18.3 available)
  test_api 0.7.10 (0.7.12 available)
  vector_math 2.2.0 (2.4.0 available)
Got dependencies!
4 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing tictactoe...

No issues found! (ran in 16.3s)
```

**Result: PASS — zero issues**

---

### flutter test

```
Resolving dependencies...
Downloading packages...
  matcher 0.12.19 (0.12.20 available)
  meta 1.17.0 (1.18.3 available)
  test_api 0.7.10 (0.7.12 available)
  vector_math 2.2.0 (2.4.0 available)
Got dependencies!
4 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading D:/Development/tictactoe/test/widget_test.dart
00:00 +0: Counter increments smoke test
00:00 +1: All tests passed!
```

**Result: PASS — 1/1 tests passed**

---

### git log

```
44e8e20 chore(init): project scaffold with docs and copyright headers
```

**Branch:** `milestone/00-project-setup`

---

### flutter run — manual verification (2026-06-11)

```
flutter run -d windows   → PASS — standard Flutter counter scaffold displayed
flutter run -d chrome    → PASS — standard Flutter counter scaffold displayed
```

**Verified by:** FullStackShack

---

### Notes

- 4 packages report newer versions incompatible with current constraints — cosmetic dependency resolver warnings, not errors. Will evaluate for upgrade in a future milestone.
