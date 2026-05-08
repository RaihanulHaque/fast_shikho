# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**দ্রুত শিখো (Fast Shikho)** — an AI study companion for Bangladeshi science students (SSC / HSC / Admission). Students upload handwritten notes or PDFs and receive an AI-generated study package with four modules: Key Points, Practice Examples, Top Questions, and Quick Test. The full product spec is in `docs/shikho_srs_document.md`.

The Flutter app is currently in **prototype / dummy-data phase**. All service calls in `lib/services/app_services.dart` simulate network delays and return hardcoded data from `lib/services/dummy_data.dart`. The real backend (Django + Gemini Flash + S3 + Celery) is described in the SRS but not yet wired up.

## Commands

```bash
# Run on Chrome (primary dev target)
flutter run -d chrome

# Run on connected Android device
flutter run -d android

# Analyze for lint errors
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Get dependencies
flutter pub get

# Build web release
flutter build web
```

## Architecture

### State Management

Provider with two top-level `ChangeNotifier` services registered in `main.dart`:

- **`AuthService`** — login/register/logout, holds `User?` (drives `LoginScreen` vs `MainShell` gate in `FastShikhoApp`)
- **`SessionService`** — session list CRUD, `uploadAndProcess()` lifecycle simulation, `getSessionContent()` returning `StudyPackage`

Screens use `context.read<T>()` for one-shot calls and `Consumer<T>` / `context.watch<T>()` for reactive rebuilds.

### Navigation

`MainShell` (bottom nav, 3 tabs: Home / History / Profile) is the root after auth. Session detail is pushed imperatively (`Navigator.push`) from `HomeScreen` or `HistoryScreen`.

`SessionDetailScreen` is a 4-step flow (PageView, non-swipeable) with a step indicator in the AppBar. Steps: পাঠ → অনুশীলন → প্রশ্নব্যাংক → কুইক টেস্ট. Each step tab lives in `lib/screens/session/widgets/`.

### Data Models (`lib/models/`)

All models are plain Dart classes with `fromJson` factories — no code-gen. The hierarchy mirrors the Gemini API JSON schema exactly:

```
StudyPackage
  ├── KeyPoints
  │     ├── List<ImportantPointQA>  (type: mcq | true_false | fill_in_the_blanks | connecting_answer)
  │     ├── List<EasyLesson>
  │     └── List<MathExample>?      (null for non-math subjects)
  ├── List<PracticeExample>          (is_math flag, needs_diagram flag)
  ├── List<TopQuestion>              (question_type: short_answer | creative | mcq | broad_answer)
  └── List<QuickTestMCQ>
```

`Session` status lifecycle: `pending → uploaded → processing → partial → complete / failed`. The `partial` state means key_points/top_questions/quick_test are ready but practice_examples (with diagrams) are still generating.

### Theme (`lib/theme/`)

- `AppColors` — all color constants (primary `#4A6CF7`, scaffoldBg `#F8F9FC`, etc.)
- `AppTheme.lightTheme` — Material theme wired to `AppColors`
- Font: **Hind Siliguri** (Google Fonts) is used throughout for all Bengali and English text — always use `GoogleFonts.hindSiliguri(...)` for `TextStyle`

### Theme & Design System

The app uses a **dark theme** matching `docs/app_ux/` HTML design files. Reference designs:
- `docs/app_ux/home.html` → HomeScreen
- `docs/app_ux/concept.html` → SessionDetailScreen (Key Points tab)
- `docs/app_ux/practice.html` → PracticeTab
- `docs/app_ux/faq.html` → TopQuestionsTab
- `docs/app_ux/dashboard.html` → ProfileScreen

Key design tokens (all in `AppColors`):
- Primary: `#58CC02` (Duolingo green) — never use raw hex, always use `AppColors.primary`
- Background: `#0B1114` (`AppColors.scaffoldBg`)
- Card surface: `rgba(255,255,255,0.03)` (`AppColors.cardBg`) — very low opacity on dark bg
- Card border: `rgba(255,255,255,0.08)` (`AppColors.cardBorder`)
- Muted text: `#8A9CA8` (`AppColors.textSecondary`)
- XP/points: `#FFC800` (`AppColors.xpYellow`)
- Streak: `#FF6B00` (`AppColors.streakOrange`)

Button style: **Duolingo 3D press** — `border-bottom: 3px` that compresses to `1px` on tap with `translateY(2px)`. See `_DuoButton` in `new_session_screen.dart` for the Flutter implementation pattern.

The loading screen (`lib/screens/widgets/panda_loading.dart`) uses a `CustomPainter` panda face with `AnimationController` for:
- Thinking tilt (0–5° back and forth, 3s cycle)  
- Blink (every 4s, 150ms animation)
- Animated green progress bar (18s to reach 88%)

### Key Conventions

- All UI text shown to users is in **Bengali** (বাংলা). English is only used in code identifiers, section labels (DASHBOARD, LEADERBOARD), and comments.
- `AppColors` is the single source of truth for all colors — never use raw `Color()` values in widgets.
- Fonts: `GoogleFonts.hindSiliguri` for Bengali body text, `GoogleFonts.plusJakartaSans` for English labels/badges/stats.
- Glass cards: `color: AppColors.cardBg`, `border: Border.all(color: AppColors.cardBorder)`, `borderRadius: 20`. See `_GlassCard` in `home_screen.dart`.
- Dummy data lives exclusively in `lib/services/dummy_data.dart`. When replacing with real API calls, only `app_services.dart` should change — models and screens remain untouched.
- The points/unlock system (earn points by attempting problems, spend to reveal answers) is a product feature tracked client-side in this prototype; server-side enforcement is described in the SRS Section 4.
