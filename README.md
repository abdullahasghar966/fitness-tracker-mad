# FitTrack

A Flutter fitness tracking app built around a dark, high-contrast design system —
animated progress rings, a drum-wheel scroll effect, and full CRUD across workouts,
meals, weight and goals.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/state-Provider-4CAF50)
![Tests](https://img.shields.io/badge/tests-52%20passing-brightgreen)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%7C%20Web-lightgrey)

> **Scope:** this is a front-end / UI project. All data is in-memory mock data seeded
> in `FitnessProvider`. There is no backend, no database and no persistence — closing
> the app resets everything. That is deliberate, not an oversight.

---

## Table of contents

- [Features](#features)
- [Tech stack](#tech-stack)
- [Getting started](#getting-started)
- [Running the tests](#running-the-tests)
- [Project structure](#project-structure)
- [Architecture](#architecture)
- [Design system](#design-system)
- [Engineering notes](#engineering-notes)
- [Code quality pass](#code-quality-pass)
- [Known limitations](#known-limitations)
- [Team](#team)

---

## Features

The app is five tabs behind a custom bottom navigation bar with a sliding accent
indicator. All five live inside an `IndexedStack`, so scroll positions and
animations survive tab switches.

### Dashboard
- Time-aware greeting (morning / afternoon / evening) and the current date
- Two animated rings — steps and calories burned — drawn with a `CustomPainter`
  and eased in over 1200 ms
- Three stat cards: workouts, active minutes, water intake, each with its own
  mini progress bar
- **Today's Workout** card listing the day's exercises, with a START WORKOUT
  button that jumps straight to the workout tab
- Weekly summary strip: seven day-circles marking completed sessions

### Workout Log
- Exercise cards that expand to reveal every set, with an ink ripple that paints
  above the card rather than behind it
- Per-set checkbox to mark a set complete; a `done / total` badge tracks progress
- Add or delete exercises and sets; deleting a set renumbers the survivors so
  set numbers stay a gapless `1..n`
- Tap through to a **detail screen** with a Hero transition on the exercise name,
  a full set table with LOG/DONE toggles, and TOTAL SETS / COMPLETED / TOTAL REPS
  summary cards
- Bodyweight exercises display `BW` instead of `0 kg`

### Meal Log
- Four macro rings — calories, protein, carbs, fat — against daily targets
- Animated macro target bars underneath
- Meals grouped into Breakfast / Lunch / Dinner / Snack, each section showing its
  own calorie subtotal; empty sections hide themselves
- Tap any meal to edit or delete it; a pulsing FAB adds a new one
- Every meal row carries colour-coded P / C / F tags

### Progress
- Weight trend line chart (`fl_chart`) with a gradient fill under the curve
- Period filter — 1W / 1M / 3M / 6M — that reslices the data
- A change badge showing weight delta **over the selected period**, coloured by
  direction of travel
- Body measurements list (chest, waist, hips, thighs, arms) with add / edit / delete

### Goals
- Overall progress header averaging every goal into a single percentage
- Goal cards with a 4 px accent strip, icon, progress bar and percentage badge
- Add goals through a bottom sheet; edit or delete from the card itself
- Validation rejects blank titles and non-positive targets with inline errors

---

## Tech stack

| Package        | Version   | Role                                                   |
|----------------|-----------|--------------------------------------------------------|
| `provider`     | `^6.1.2`  | `ChangeNotifier` state management                      |
| `google_fonts` | `^6.2.0`  | Barlow Condensed, Barlow and Inter typefaces           |
| `fl_chart`     | `^0.68.0` | Weight trend line chart on the Progress screen         |
| `flutter_lints`| `^3.0.0`  | Static analysis ruleset (dev)                          |

Dart SDK `>=3.0.0 <4.0.0`.

---

## Getting started

### Prerequisites

- Flutter SDK 3.x with Dart 3 ([install guide](https://docs.flutter.dev/get-started/install))
- A target toolchain: Visual Studio with the C++ desktop workload for Windows,
  Android Studio for Android, or any Chromium browser for web

### Setup

```bash
git clone https://github.com/abdullahasghar966/fitness-tracker-mad.git
```

```bash
cd fitness-tracker-mad
```

```bash
flutter pub get
```

### ⚠️ Regenerate the platform folders first

Only `windows/` is committed to this repository. There is no `android/`, `ios/`,
`web/`, `linux/` or `macos/` directory, so those targets will not build until the
scaffolding is generated. Run this once, from the project root:

```bash
flutter create .
```

That fills in the missing platform folders without touching anything in `lib/`.
Skip it if you only ever intend to run on Windows.

### Run

```bash
flutter run -d windows
```

```bash
flutter run -d chrome
```

```bash
flutter run -d android
```

### Build a release

```bash
flutter build apk --release
```

```bash
flutter build windows --release
```

---

## Running the tests

```bash
flutter test
```

**52 tests** cover the app:

| File | Tests | What it covers |
|------|-------|----------------|
| `test/fitness_provider_test.dart` | 44 | Every piece of provider state and CRUD, with no widgets involved — macro totals, meal category filters, set numbering, goal progress averaging, bounds-checked indices, validation rules |
| `test/widget_test.dart` | 8 | The app boots, all five nav destinations render, tab switching works, **every tab builds without throwing**, START WORKOUT routes correctly, and goal validation accepts valid input while rejecting a blank title |

Static analysis should come back clean:

```bash
flutter analyze
```

> **Writing new widget tests?** Never call `pumpAndSettle()` in this project. The
> meal screen runs a looping FAB pulse and all five screens stay alive inside the
> `IndexedStack`, so an animation is *always* in flight and `pumpAndSettle` will
> time out. Pump explicit durations instead — `await tester.pump(const Duration(milliseconds: 300))`.

---

## Project structure

```
lib/
├── main.dart                          # Entry point, MainNavigator, slideRoute helper
├── theme/
│   └── app_theme.dart                 # AppColors, AppTextStyles, AppTheme.dark
├── models/
│   └── models.dart                    # ExerciseSet, Exercise, Meal, Goal
├── providers/
│   └── fitness_provider.dart          # Single ChangeNotifier — all state and CRUD
├── screens/
│   ├── dashboard_screen.dart          # Rings, stat cards, today's workout, weekly strip
│   ├── workout_log_screen.dart        # Exercise list, expandable sets, dialogs
│   ├── workout_detail_screen.dart     # Set table, LOG/DONE, Hero target
│   ├── meal_log_screen.dart           # Macro rings and bars, meal sections
│   ├── progress_screen.dart           # Weight chart, period filter, measurements
│   └── goals_screen.dart              # Goal cards, add/edit/delete sheets
└── widgets/
    ├── volume_scroll_list.dart        # VolumeScrollList + VolumeListItem
    ├── custom_bottom_nav.dart         # Sliding tab indicator
    ├── circular_progress_widget.dart  # CustomPainter arc + easeOutCubic
    ├── stat_card.dart                 # Stat card, optional left accent
    ├── macro_progress_bar.dart        # Animated macro bars
    └── goal_card.dart                 # Goal card with accent strip

test/
├── fitness_provider_test.dart         # 44 unit tests
└── widget_test.dart                   # 8 widget tests
```

`CLAUDE.md` holds the deeper architecture guide, the per-file ownership map and
the full set of house rules.

---

## Architecture

### State management

A single `FitnessProvider` extends `ChangeNotifier` and owns everything: seeded
mock data, the selected tab index, derived getters (`totalCalories`,
`overallGoalProgress`, …) and every CRUD method.

```dart
final provider = context.watch<FitnessProvider>();  // rebuild on change
final provider = context.read<FitnessProvider>();   // one-shot, inside callbacks
Consumer<FitnessProvider>(builder: (ctx, provider, child) { ... });
```

Every index-taking method bounds-checks its arguments and quietly no-ops instead
of throwing, so a stale index from a rebuilt list can't crash the app.

### Navigation

`MainNavigator` drives an `IndexedStack` — all five screens stay mounted, so
scroll offsets and in-flight animations are preserved across tab switches. Tab
changes go through `provider.setIndex(index)`, never `setState`.

Push navigation uses one shared helper for a consistent 250 ms slide + fade:

```dart
Navigator.push(
  context,
  MainNavigator.slideRoute(
    WorkoutDetailScreen(exercise: exercise, heroTag: heroTag),
  ),
);
```

### The scroll system

`VolumeScrollList` is the standard scrollable across the app — a drop-in
replacement for `SingleChildScrollView` that layers two effects:

1. **Reveal** — each item fades and slides up on first build, staggered by
   `index × 65 ms` and clamped at 400 ms
2. **Volume / drum-wheel** — while scrolling, items far from the screen centre
   shrink up to 10 % and fade up to 35 %, so the focal item stays dominant

Use `VolumeListItem` directly when you manage your own `ScrollController`.

---

## Design system

Everything comes from `lib/theme/app_theme.dart`. Colours and text styles are
never hardcoded inline.

### Palette

| Token          | Hex        | Used for                        |
|----------------|------------|---------------------------------|
| `background`   | `#0D0D0D`  | Page background                 |
| `surface`      | `#1A1A1A`  | Cards and containers            |
| `accent`       | `#E8FF00`  | Primary accent (acid yellow)    |
| `accentRed`    | `#FF3D00`  | Secondary accent, calories ring |
| `textPrimary`  | `#F5F5F5`  | Headings and values             |
| `textMuted`    | `#7A7A7A`  | Labels and subtitles            |
| `divider`      | `#2C2C2C`  | Borders and separators          |

Macro accents: protein `#4ECDC4`, carbs `#FFB347`, fat `#FF6B35`.

### Typography

| Family            | Where it's used                          |
|-------------------|------------------------------------------|
| Barlow Condensed  | Display text, headings, large stat values |
| Inter             | Body copy, labels, captions              |
| Barlow            | Button labels and badges                 |

---

## Engineering notes

Three patterns in this codebase exist for non-obvious reasons. Breaking them
reintroduces real bugs.

### 1. The left accent border pattern

A card with a 4 px coloured left edge **cannot** be built with a `BoxDecoration`
that mixes border widths and sets `borderRadius`. Flutter asserts
*"A borderRadius can only be given for a uniform Border"* and red-screens at
paint time. Draw the strip as a child instead:

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.divider, width: 1),  // uniform
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4, color: AppColors.accent),  // the accent strip
          Expanded(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          ),
        ],
      ),
    ),
  ),
)
```

Used by `GoalCard`, `StatCard(accentLeft: true)`, the dashboard workout card and
the goals header.

### 2. Dialogs own their controllers

Each dialog and bottom sheet is its own `StatefulWidget` that disposes its
`TextEditingController`s in `dispose()`. Disposing right after
`await showDialog(...)` throws *"used after being disposed"*, because the future
completes while the dismissal animation is still rendering the fields.

### 3. Guard every progress value

`Goal.progress` returns `0` when `target <= 0`. `NaN` survives `.clamp()` and
then trips assertions deep inside `LinearProgressIndicator` and
`FractionallySizedBox`, so any `widthFactor` or progress value gets clamped
before it reaches a widget.

### House rules

- `flutter analyze` must return **No issues found!** before committing
- Use `.withValues(alpha: x)` — never the deprecated `.withOpacity()`
- Use `debugPrint()` — never `print()`
- `DropdownButtonFormField` takes `initialValue:`, not the deprecated `value:`

---

## Code quality pass

The repository went through a full audit. Every issue below was found by reading
the code and is fixed in the commit history.

| Severity | Issue | Resolution |
|----------|-------|------------|
| 🔴 Critical | Opening the **Goals tab crashed** — the progress header mixed a 4 px left border with `borderRadius`, tripping Flutter's uniform-border assertion | Rebuilt with the accent-strip pattern |
| 🟠 High | `WorkoutDetailScreen` was fully written but **unreachable** — nothing navigated to it, and the `slideRoute` helper built to reach it was never called | Wired up with a row-unique Hero tag |
| 🟠 High | `test/widget_test.dart` was still the **stock counter boilerplate** — it asserted on a `'0'` this app never renders, so the suite was red | Replaced with 52 real tests |
| 🟡 Medium | `WorkoutLogScreen` ignored the design system entirely, using raw Material widgets and hardcoded greys | Restyled onto `AppColors` and `VolumeScrollList` |
| 🟡 Medium | Three conflicting weekly workout targets (`4` in the provider, `7.0` hardcoded in the workout log) | Single source of truth in the provider |
| 🟡 Medium | The weight badge was **always green** and always compared the full dataset, ignoring the period filter above it | Measures the selected period, colours by direction |
| 🔵 Low | `Exercise.sets` defaulted to `const []`, so a set added to any exercise built without a list threw *"Cannot add to an unmodifiable list"* | Constructor copies into a growable list |
| 🔵 Low | Dead code: `reveal_on_scroll.dart`, `staggered_list.dart`, and two stale analyzer dumps whose errors had already been fixed | Deleted |
| 🔵 Low | `sensors_plus` was declared but never imported — step counts are static mock data | Removed from `pubspec.yaml` |
| 🔵 Low | Dialogs accepted empty names and negative numbers, gave no feedback on failure, and leaked their controllers | Validation with inline errors, controllers disposed |

---

## Known limitations

These are open by design or left as future work:

- **No persistence.** Everything resets on restart. Adding `shared_preferences`
  or a local database would be the natural next step.
- **`google_fonts` fetches typefaces over the network at runtime.** On a first
  launch with no connection the app silently falls back to the system font and
  the typography is lost. Bundling the `.ttf` files under `assets/fonts/` and
  declaring them in `pubspec.yaml` would make the design offline-proof.
- **Step and calorie counts are static mock values**, not sensor readings.
- **Only `windows/` platform scaffolding is committed** — run `flutter create .`
  to generate the rest.
- Models rely on object identity for edit and delete rather than implementing
  `==` and `hashCode`, which is fine in memory but would need revisiting
  alongside persistence.

---

## Team

Built as a Mobile Application Development (MAD) semester project —
roll numbers **FA23-BCS-110, FA23-BCS-130, FA23-BCS-140**.

| Member   | Area |
|----------|------|
| Abdullah | Core foundation — app shell, state management, design system, data models, Dashboard |
| Muneeb   | Workout log, workout detail, and the `VolumeScrollList` scroll animation system |
| Nabeel   | Meal log, Progress, Goals, and the macro bar / goal card widgets |

---

<div align="center">
Built with Flutter.
</div>
