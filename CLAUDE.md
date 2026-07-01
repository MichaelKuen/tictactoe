# CLAUDE.md — Tic Tac Toe Flutter Project

This file is the authoritative reference for Claude Code in this project.
Read it in full before taking any action in any session.

---

## Project Identity

| Field            | Value                          |
|------------------|-------------------------------|
| App name         | Tic Tac Toe                   |
| Package          | com.fullstackshack.tictactoe  |
| Owner            | FullStackShack                |
| Platform targets | Android, Web (primary); iOS, macOS, Windows, Linux (secondary) |
| Flutter channel  | stable                        |
| Min SDK          | Android: flutter.minSdkVersion |

---

## Copyright Header

Every `.dart` file in `lib/` and `test/` must start with these two lines — no blank line before the first import:

```
// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
```

The `.dart_tool/` directory is generated — do NOT add headers there.

---

## Session Rules

1. **Read this file in full before doing anything else.**
2. Never move to the next milestone until the user explicitly confirms the current one is done.
3. At the end of every session that changes code or docs, update `BUILD_LOG.md` with every command run (exact output, nothing summarised) and `CHANGELOG.md` with what changed.
4. After each milestone is complete, create or update `docs/milestone_XX_<name>.md`.
5. All commits go to a `milestone/XX-<slug>` branch first; merge to `main` only on user confirmation.

---

## Milestone Plan

| # | Branch                        | Goal                                 | Status  |
|---|-------------------------------|--------------------------------------|---------|
| 00 | milestone/00-project-setup   | Scaffold, docs, copyright, git init  | ✅ Complete (confirmed 2026-06-11) |
| 01 | milestone/01-game-logic       | Core game state & logic (no UI)      | ✅ Complete (merged to main 2026-06-25) |
| 02 | milestone/02-basic-ui         | Grid, X/O rendering, tap to play     | ✅ Complete (merged to main 2026-06-25) |
| 03 | milestone/03-win-detection    | Win/draw detection, end-game UI      | ✅ Complete (merged to main 2026-06-25) |
| 04 | milestone/04-ai-player        | Minimax AI, contrast colours, Windows layout | ✅ Complete (confirmed 2026-07-01) |
| 05 | milestone/05-admob            | Google AdMob integration (banner, interstitial, rewarded) | ⏳ Pending |
| 06 | milestone/06-polish           | Animations, sound, theming           | ⏳ Pending |

---

## Branch & Commit Conventions

- **Branch format:** `milestone/XX-<short-slug>` (e.g. `milestone/01-game-logic`)
- **Commit format:** `type(scope): message` — types: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`
- **Examples:**
  - `chore(init): project scaffold with docs and copyright headers`
  - `feat(game): implement core board state and move validation`

---

## Quality Gates (must pass before any milestone commit)

```
flutter analyze   # zero issues
flutter test      # all pass
```

---

## File Templates

### README.md

```markdown
# Tic Tac Toe

A Flutter Tic Tac Toe game targeting Android and Web.

**Owner:** FullStackShack  
**Package:** com.fullstackshack.tictactoe  
**Flutter:** 3.41.4 | **Dart:** 3.11.1

## Getting Started

```bash
flutter pub get
flutter run -d chrome       # Web
flutter run -d <device-id>  # Android
```

## Project Structure

```
lib/
  main.dart         # App entry point
test/
  widget_test.dart  # Widget tests
docs/               # Milestone documentation
```

## Milestones

See [BUILD_LOG.md](BUILD_LOG.md) for session history.
```

---

### BUILD_LOG.md

```markdown
# Build Log

All commands run during development, with exact output. Nothing summarised.

---

## Milestone 00 — Project Setup

**Date:** YYYY-MM-DD  
**Flutter:** x.x.x  
**Dart:** x.x.x  

### Commands & Output

(paste exact terminal output here)
```

---

### CHANGELOG.md

```markdown
# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

## [0.1.0] — YYYY-MM-DD — Milestone 00: Project Setup

### Added
- Flutter project scaffold (com.fullstackshack.tictactoe)
- CLAUDE.md, README.md, BUILD_LOG.md, CHANGELOG.md
- docs/milestone_00_setup.md
- Copyright headers on all .dart files
- git repository initialised on `main` branch
```

---

### docs/milestone_XX_setup.md

```markdown
# Milestone 00 — Project Setup

**Date:** YYYY-MM-DD  
**Branch:** milestone/00-project-setup  
**Status:** ✅ Complete

## Objectives

- [x] Create Flutter project with correct org ID
- [x] Create documentation files
- [x] Add copyright headers to all .dart files
- [x] Initialise git repository
- [x] Run flutter analyze — zero issues
- [x] Run flutter test — all pass

## Notes

(any issues and resolutions go here)
```

---

## Do Not

- Do not commit to `main` directly.
- Do not skip `flutter analyze` or `flutter test` before a milestone commit.
- Do not add third-party packages without noting them in `CHANGELOG.md`.
- Do not remove the copyright header from any `.dart` file.
- Do not add emoji to code files.
