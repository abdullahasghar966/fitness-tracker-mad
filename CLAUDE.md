# FitTrack — CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.

---

## Project Overview

**FitTrack** is a Flutter fitness tracking application with five main screens:
- **Dashboard** — daily stats, circular progress rings, today's workout card, weekly summary
- **Workout Log** — expandable exercise list with sets/reps/weight
- **Meal Log** — macro tracking with category sections (Breakfast, Lunch, Dinner, Snack)
- **Progress** — weight trend chart (fl_chart) + body measurements
- **Goals** — goal cards with progress bars and CRUD operations

**State management:** Single `FitnessProvider` (ChangeNotifier via Provider). All data is in-memory (no persistence).

---

## Commands

```bash
flutter pub get                         # Install dependencies
flutter run -d chrome                   # Run on Chrome (web)
flutter run -d windows                  # Run on Windows desktop (requires VS toolchain)
flutter build apk                       # Build Android APK
flutter analyze                         # Lint / static analysis — must return "No issues found!"
flutter test                            # Run all tests
flutter test test/widget_test.dart      # Run single test file
```

---

## Architecture

### State Management

Single `FitnessProvider` (`lib/providers/fitness_provider.dart`) extends `ChangeNotifier`. It holds:
- All mock data (steps, calories, meals, goals, weight, measurements, exercises)
- Selected bottom-nav tab index (`selectedIndex`)
- Derived getters (`totalCalories`, `totalProtein`, `totalCarbs`, `totalFat`, `overallGoalProgress`)
- All CRUD methods (`addMeal`, `editMeal`, `deleteMeal`, `addGoal`, `updateGoal`, `deleteGoal`, etc.)

Screens access it via:
```dart
final provider = context.watch<FitnessProvider>();   // rebuild on change
final provider = context.read<FitnessProvider>();    // one-shot read (inside callbacks)
Consumer<FitnessProvider>(builder: (ctx, provider, child) { ... })
```

### Navigation

`MainNavigator` in `main.dart` uses `IndexedStack` — preserves scroll/animation state across tabs. Custom `CustomBottomNav` drives tab switching. For push navigation (workout detail), use the static helper:

```dart
Navigator.push(context, MainNavigator.slideRoute(WorkoutDetailScreen(exercise: exercise)));
```

This gives consistent slide+fade transitions (250ms, `Curves.easeOut`).

### Design System (`lib/theme/app_theme.dart`)

```dart
// Colors — never hardcode inline
AppColors.background   // 0xFF0D0D0D  — page background
AppColors.surface      // 0xFF1A1A1A  — card/container background
AppColors.accent       // 0xFFE8FF00  — primary accent (yellow-green)
AppColors.accentRed    // 0xFFFF3D00  — secondary accent (red-orange)
AppColors.textPrimary  // 0xFFF5F5F5  — headings / values
AppColors.textMuted    // 0xFF7A7A7A  — labels / subtitles
AppColors.divider      // 0xFF2C2C2C  — borders / separators

// Text styles — never hardcode inline
AppTextStyles.displayLarge    // BarlowCondensed 48 w900
AppTextStyles.headlineMedium  // BarlowCondensed 20 w700
AppTextStyles.bodyMedium      // Inter 14 w400
AppTextStyles.labelSmall      // Inter 10 w400 textMuted
// ... see full list in app_theme.dart
```

`AppTheme.dark` is the single `ThemeData` passed to `MaterialApp`.

### Animation Patterns

**Primary scroll system — `VolumeScrollList`** (`lib/widgets/volume_scroll_list.dart`):
- Use `VolumeScrollList(children: [...])` to replace `SingleChildScrollView` on any screen.
- Combines two effects:
  1. GSAP-style reveal: each item slides up + fades in, staggered by `index × 65ms` (clamped at 400ms)
  2. Volume / drum-wheel: items far from screen centre shrink (−10%) and fade (−35%) while scrolling
- Use `VolumeListItem(scrollController: ctrl, revealDelay: ..., child: ...)` inside existing `ListView.builder` screens where you manage your own `ScrollController`.
- All scrollables use `BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())`.

**Other animations:**
- Circular progress ring: `CircularProgressWidget` — animates from 0 on init via `CurvedAnimation(Curves.easeOutCubic)`, 1200ms.
- FAB pulse: `AnimationController` (1.0→1.08, `repeat(reverse: true)`) wrapped in `ScaleTransition`.
- Stat number updates: `AnimatedContainer` 300ms in `StatCard`.

### Left Accent Border Pattern — CRITICAL

Cards with a 4px coloured left border **cannot** use `BoxDecoration` with mixed border widths + `borderRadius` — Flutter throws a runtime assertion error. Always use this pattern:

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
          Container(width: 4, color: AppColors.accent),  // left accent strip
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

This pattern is already applied in: `GoalCard`, `StatCard` (accentLeft), dashboard Today's Workout card.

---

## File Layout

```
lib/
  main.dart                          # App entry, MainNavigator, slideRoute helper
  theme/
    app_theme.dart                   # AppColors, AppTextStyles, AppTheme.dark
  models/
    models.dart                      # ExerciseSet, Exercise, Meal, Goal
  providers/
    fitness_provider.dart            # Single ChangeNotifier — all state & CRUD
  screens/
    dashboard_screen.dart            # Home: greeting, rings, stat cards, workout, weekly
    workout_log_screen.dart          # Exercise list, expandable sets, add exercise/set
    workout_detail_screen.dart       # Full exercise detail, set logging, Hero target
    meal_log_screen.dart             # Meal sections, macro circles, add/edit/delete meal
    progress_screen.dart             # Weight trend chart, period filter, body measurements
    goals_screen.dart                # Goal cards, add/edit/delete goal
  widgets/
    volume_scroll_list.dart          # VolumeScrollList + VolumeListItem (primary scroll)
    custom_bottom_nav.dart           # AnimatedPositioned tab indicator
    circular_progress_widget.dart    # CustomPainter arc + easeOutCubic animation
    stat_card.dart                   # AnimatedContainer 300ms, accentLeft pattern
    macro_progress_bar.dart          # Animated macro progress bars (MacroProgressBar)
    goal_card.dart                   # Goal card with left accent strip
    reveal_on_scroll.dart            # Legacy reveal widget — prefer VolumeScrollList
    staggered_list.dart              # Legacy stagger widget — prefer VolumeScrollList
```

---

## Key Dependencies

| Package        | Purpose                                                             |
|----------------|---------------------------------------------------------------------|
| `provider`     | ChangeNotifierProvider / Consumer / context.watch                   |
| `google_fonts` | Barlow Condensed, Inter, Barlow typefaces                           |
| `fl_chart`     | LineChart (weight trend) in ProgressScreen                          |
| `sensors_plus` | Step counter stub — real sensor calls mocked with static data       |

---

## Known Rules

- Run `flutter analyze` before committing — must return **No issues found!**
- Never use `withOpacity()` — use `.withValues(alpha: x)` instead.
- Never use `print()` — use `debugPrint()` or remove.
- Never use `FormField.value` (deprecated) — use `initialValue`.
- Remove deprecated `background`/`onBackground` from `ColorScheme.dark()` — use `surface`/`onSurface`.
- `DropdownButtonFormField` uses `initialValue:` not `value:` (deprecated after v3.33.0).

---
---

# Team Division

## 👤 Abdullah — Core Foundation + Dashboard + App Shell

**Responsibility:** App entry point, state management, design system, data models, and the Home (Dashboard) screen.

### Files Owned

| File | Role |
|------|------|
| `lib/main.dart` | App entry, MaterialApp, MainNavigator, IndexedStack, slideRoute |
| `lib/theme/app_theme.dart` | AppColors, AppTextStyles, AppTheme.dark |
| `lib/models/models.dart` | ExerciseSet, Exercise, Meal, Goal data models |
| `lib/providers/fitness_provider.dart` | All state, mock data, CRUD methods |
| `lib/screens/dashboard_screen.dart` | Home screen — greeting, stats, workout card, weekly summary |
| `lib/widgets/custom_bottom_nav.dart` | Bottom navigation bar with sliding indicator |
| `lib/widgets/circular_progress_widget.dart` | Animated circular progress rings |
| `lib/widgets/stat_card.dart` | Stat cards (steps/calories/water) with accent border |

---

### `lib/main.dart`

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FitnessProvider(),
      child: MaterialApp(
        title: 'FitTrack',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const MainNavigator(),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  // Static helper for consistent slide+fade push transitions
  static Route<T> slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (ctx, anim, _) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (ctx, anim, _, child) {
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return SlideTransition(position: slide, child: FadeTransition(opacity: anim, child: child));
      },
    );
  }
}
```

**Key responsibilities in `main.dart`:**
- Wraps entire app in `ChangeNotifierProvider<FitnessProvider>`
- `IndexedStack` preserves screen state (scroll positions, animations) across tab switches
- `_onTabTap` delegates to `provider.setIndex(index)` — never call `setState` for tab switching

---

### `lib/models/models.dart`

```dart
class ExerciseSet {
  final int setNumber;
  final int reps;
  final double weight;
  final bool isCompleted;

  ExerciseSet({required this.setNumber, required this.reps,
               required this.weight, this.isCompleted = false});

  // Immutable update pattern — always use copyWith, never mutate directly
  ExerciseSet copyWith({bool? isCompleted}) => ExerciseSet(
    setNumber: setNumber, reps: reps, weight: weight,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class Exercise {
  final String name;
  final String category;   // e.g. "Chest", "Back"
  final String bodyPart;
  final String equipment;
  List<ExerciseSet> sets;
  bool isExpanded;         // UI expansion state — toggled by FitnessProvider.toggleExercise()

  int get totalSets => sets.length;
  int get completedSets => sets.where((s) => s.isCompleted).length;
}

class Meal {
  final String name;
  final String category;   // 'Breakfast' | 'Lunch' | 'Dinner' | 'Snack'
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
}

class Goal {
  final String title;
  final String subtitle;
  final double current;
  final double target;
  final String unit;
  final IconData icon;

  double get progress => (current / target).clamp(0.0, 1.0);
}
```

---

### `lib/providers/fitness_provider.dart` — Key Sections

```dart
class FitnessProvider extends ChangeNotifier {
  // ── Navigation ─────────────────────────────────────────────────
  int selectedIndex = 0;
  void setIndex(int index) { selectedIndex = index; notifyListeners(); }

  // ── Daily Stats (mock data) ────────────────────────────────────
  String userName = 'Zia';
  bool hasNotifications = true;
  int steps = 7843;           int stepsGoal = 10000;
  int caloriesBurned = 485;   int caloriesGoal = 750;
  int workoutsThisWeek = 3;   int workoutsGoal = 4;
  int activeMinutes = 142;    int activeMinutesGoal = 200;
  double waterIntake = 1.8;   double waterGoal = 2.5;
  int todayWorkoutDuration = 45;
  String todayWorkoutName = 'UPPER BODY POWER';
  String todayWorkoutFocus  = 'CHEST & BACK';

  // ── Exercises ──────────────────────────────────────────────────
  List<Exercise> todayExercises = [ /* Bench Press, Pull-Up */ ];

  void toggleExercise(int index) { ... notifyListeners(); }
  void toggleSet(int exerciseIndex, int setIndex) { ... notifyListeners(); }
  void addExercise(String name) { ... notifyListeners(); }
  void addSet(int exerciseIndex, int reps, double weight) { ... notifyListeners(); }
  void updateExerciseSets(Exercise exercise, List<ExerciseSet> newSets) { ... notifyListeners(); }
  void startWorkout() { /* hook for future implementation */ }

  // ── Meals ──────────────────────────────────────────────────────
  List<Meal> meals = [ /* Oatmeal with Berries */ ];

  int    get totalCalories => meals.fold(0,   (s, m) => s + m.calories);
  double get totalProtein  => meals.fold(0.0, (s, m) => s + m.protein);
  double get totalCarbs    => meals.fold(0.0, (s, m) => s + m.carbs);
  double get totalFat      => meals.fold(0.0, (s, m) => s + m.fat);

  List<Meal> get breakfastMeals => meals.where((m) => m.category == 'Breakfast').toList();
  List<Meal> get lunchMeals     => meals.where((m) => m.category == 'Lunch').toList();
  List<Meal> get dinnerMeals    => meals.where((m) => m.category == 'Dinner').toList();
  List<Meal> get snackMeals     => meals.where((m) => m.category == 'Snack').toList();

  void addMeal(Meal meal)                  { meals.add(meal);               notifyListeners(); }
  void editMeal(Meal old, Meal next)       { meals[meals.indexOf(old)] = next; notifyListeners(); }
  void deleteMeal(Meal meal)               { meals.remove(meal);             notifyListeners(); }

  // ── Goals ──────────────────────────────────────────────────────
  late List<Goal> goals;  // initialised in constructor

  double get overallGoalProgress =>
      goals.isEmpty ? 0.0 : goals.fold(0.0, (s, g) => s + g.progress) / goals.length;

  void addGoal(String title, double current, double target, String unit) { ... notifyListeners(); }
  void updateGoal(int index, double current, double target)              { ... notifyListeners(); }
  void deleteGoal(int index)                                             { ... notifyListeners(); }

  // ── Weight ─────────────────────────────────────────────────────
  List<double> weightData = [ 82.5, 82.1, 81.8, 81.6, 81.2, 80.9,
                               80.7, 80.4, 80.1, 79.9, 79.7, 79.5 ];

  void addWeight(double weight)            { weightData.add(weight);         notifyListeners(); }
  void editWeight(int index, double w)     { weightData[index] = w;          notifyListeners(); }
  void deleteWeight(int index)             { weightData.removeAt(index);     notifyListeners(); }

  // ── Body Measurements ──────────────────────────────────────────
  Map<String, double> bodyMeasurements = {
    'Chest': 102.5, 'Waist': 82.0, 'Hips': 98.5,
    'Thighs': 58.0, 'Upper Arms': 36.5,
  };

  void addMeasurement(String name, double value)                   { ... notifyListeners(); }
  void editMeasurement(String old, String newName, double newVal)  { ... notifyListeners(); }
  void deleteMeasurement(String name)                              { ... notifyListeners(); }
}
```

---

### `lib/screens/dashboard_screen.dart` — Key Widget Tree

```
Scaffold
└── AppBar (FITTRACK logo + notification bell with hasNotifications dot)
└── VolumeScrollList
    ├── Column — Greeting + userName + date
    ├── SizedBox(24)
    ├── Container — Circular progress rings row
    │   ├── CircularProgressWidget (steps / stepsGoal, accent)
    │   └── CircularProgressWidget (caloriesBurned / caloriesGoal, accentRed)
    ├── SizedBox(16)
    ├── Row — Stat cards
    │   ├── StatCard('WORKOUTS', workoutsThisWeek, workoutsGoal)
    │   ├── StatCard('ACTIVE MIN', activeMinutes, activeMinutesGoal)
    │   └── StatCard('WATER', waterIntake, waterGoal, accentLeft: true)
    ├── SizedBox(16)
    ├── Container — Today's Workout card  ← LEFT ACCENT BORDER PATTERN
    │   ├── Header row (TODAY'S WORKOUT + duration badge)
    │   ├── todayWorkoutName + todayWorkoutFocus
    │   ├── Divider
    │   ├── Exercise list (todayExercises.take(6))
    │   └── START WORKOUT button → provider.startWorkout()
    ├── SizedBox(16)
    └── Container — Weekly Summary
        └── Row of 7 day circles (weeklyStatus map)
```

**Important:** The Today's Workout card and `StatCard(accentLeft: true)` both use the **Left Accent Border Pattern** (see Architecture section). Do NOT use `Border(left: width 4, others: width 1)` with `borderRadius`.

---

### `lib/widgets/circular_progress_widget.dart`

```dart
// Usage:
CircularProgressWidget(
  progress: provider.steps / provider.stepsGoal,  // 0.0–1.0
  size: 130,
  strokeWidth: 10,
  color: AppColors.accent,
  label: 'STEPS',
  value: provider.steps.toString(),
  unit: '/ ${provider.stepsGoal}',
)

// Internals: CustomPainter draws two arcs (background + foreground).
// AnimationController (1200ms, easeOutCubic) drives progress from 0 on init.
// didUpdateWidget resets + replays animation when progress value changes.
```

---

### `lib/widgets/stat_card.dart`

```dart
// Usage:
StatCard(
  label: 'WORKOUTS',
  value: provider.workoutsThisWeek.toString(),
  unit: 'this week',
  icon: Icons.fitness_center_outlined,
  progress: provider.workoutsThisWeek / provider.workoutsGoal,
  accentLeft: false,  // true only for WATER card
)

// When accentLeft: false  → AnimatedContainer with uniform 1px border + borderRadius
// When accentLeft: true   → Left Accent Border Pattern (outer container + ClipRRect + Row)
// Progress bar: LinearProgressIndicator inside ClipRRect(radius 2)
```

---

### `lib/widgets/custom_bottom_nav.dart`

```dart
// 5 tabs: Home, Workout, Meals, Progress, Goals
// Sliding accent bar: AnimatedPositioned (250ms, Curves.easeOut)
//   left = selectedIndex * itemWidth
//   top = 0, height = 2px, color = AppColors.accent
// Active icon/label: AppColors.accent | Inactive: AppColors.textMuted
// Height: 72px | Border top: AppColors.divider 1px
```

---
---

## 👤 Muneeb — Workout Features + Scroll Animation System

**Responsibility:** All workout-related screens (exercise list, set logging, workout detail), the primary scroll animation system (`VolumeScrollList`), and supporting animation widgets.

### Files Owned

| File | Role |
|------|------|
| `lib/screens/workout_log_screen.dart` | Expandable exercise list, add exercise/set dialogs |
| `lib/screens/workout_detail_screen.dart` | Full exercise detail with set logging, Hero target |
| `lib/widgets/volume_scroll_list.dart` | Primary scroll system (reveal + volume effects) |
| `lib/widgets/reveal_on_scroll.dart` | Legacy reveal widget (superseded by VolumeScrollList) |
| `lib/widgets/staggered_list.dart` | Legacy stagger widget (superseded by VolumeScrollList) |

---

### `lib/screens/workout_log_screen.dart` — Structure

```dart
class WorkoutLogScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      body: ListView(
        children: [
          // ── Daily stats summary card ──────────────────────────────
          Card(
            child: Row(children: [
              _statWidget("Steps",    provider.steps.toDouble(),          provider.stepsGoal.toDouble()),
              _statWidget("Calories", provider.caloriesBurned.toDouble(), provider.caloriesGoal.toDouble()),
              _statWidget("Workouts", provider.workoutsThisWeek.toDouble(), 7.0),
              _statWidget("Water",    provider.waterIntake, 2.5, isDouble: true),
            ]),
          ),

          // ── Exercises ListView.builder ─────────────────────────────
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.todayExercises.length,
            itemBuilder: (context, index) {
              final exercise = provider.todayExercises[index];
              return Card(
                child: ExpansionTile(
                  key: Key('${exercise.name}_$index'),
                  initiallyExpanded: exercise.isExpanded,
                  onExpansionChanged: (_) => provider.toggleExercise(index),
                  title: Text(exercise.name),
                  subtitle: Text('${exercise.category} • ${exercise.bodyPart} • ${exercise.equipment}'),
                  children: [
                    // Sets mapped to ListTile with Checkbox
                    ...exercise.sets.map((set) {
                      int setIndex = exercise.sets.indexOf(set);
                      return ListTile(
                        leading: Checkbox(
                          value: set.isCompleted,
                          onChanged: (_) => provider.toggleSet(index, setIndex),
                        ),
                        title: Text("Set ${set.setNumber}"),
                        subtitle: Text("${set.reps} reps • ${set.weight} kg"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Must use Future.delayed to avoid modifying list during build
                            Future.delayed(Duration.zero, () {
                              exercise.sets.removeAt(setIndex);
                              provider.updateExerciseSets(exercise, exercise.sets);
                            });
                          },
                        ),
                      );
                    }),
                    // Add Set button
                    ElevatedButton.icon(
                      onPressed: () => _showAddSetDialog(context, provider, index),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Set"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Stat row helper ─────────────────────────────────────────────
  Widget _statWidget(String title, double current, double goal, {bool isDouble = false}) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Expanded(child: Column(children: [
      Text(title),
      Text(isDouble
          ? "${current.toStringAsFixed(1)} / $goal"
          : "${current.toInt()} / ${goal.toInt()}"),
      LinearProgressIndicator(value: progress, color: Colors.greenAccent),
    ]));
  }

  // ── Add Exercise Dialog ─────────────────────────────────────────
  void _showAddExerciseDialog(BuildContext context, FitnessProvider provider) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(context: context, builder: (dialogContext) =>
      AlertDialog(
        title: const Text("Add New Exercise"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Exercise Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) provider.addExercise(result);
  }

  // ── Add Set Dialog ──────────────────────────────────────────────
  void _showAddSetDialog(BuildContext context, FitnessProvider provider, int exerciseIndex) async {
    final repsController   = TextEditingController();
    final weightController = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (dialogContext) =>
      AlertDialog(
        title: const Text("Add Set"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: repsController,   keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Reps")),
          TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Weight (kg)")),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final reps   = int.tryParse(repsController.text.trim()) ?? 0;
              final weight = double.tryParse(weightController.text.trim()) ?? 0.0;
              if (reps > 0) Navigator.pop(dialogContext, {'reps': reps, 'weight': weight});
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
    if (result != null && context.mounted)
      provider.addSet(exerciseIndex, result['reps'] as int, result['weight'] as double);
  }
}
```

---

### `lib/screens/workout_detail_screen.dart` — Key Sections

```dart
class WorkoutDetailScreen extends StatefulWidget {
  final Exercise exercise;   // passed from WorkoutLogScreen via Hero + slideRoute
  const WorkoutDetailScreen({super.key, required this.exercise});
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late List<ExerciseSet> _sets;  // local mutable copy of sets

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.exercise.sets);  // work on local copy, sync to provider on changes
  }

  // ── Set row structure ───────────────────────────────────────────
  // Each set row shows: setNumber | reps | weight | LOG/DONE button
  // Toggling LOG/DONE:
  //   setState(() { _sets[index] = ExerciseSet(..., isCompleted: !set.isCompleted); });
  //   context.read<FitnessProvider>().updateExerciseSets(widget.exercise, _sets);

  // ── Add Set button ──────────────────────────────────────────────
  // Appends a new ExerciseSet using last set's reps/weight as defaults:
  //   setState(() { _sets.add(ExerciseSet(setNumber: _sets.length + 1,
  //       reps: _sets.isNotEmpty ? _sets.last.reps : 10,
  //       weight: _sets.isNotEmpty ? _sets.last.weight : 0)); });
  //   context.read<FitnessProvider>().updateExerciseSets(widget.exercise, _sets);

  // ── Chip helper ─────────────────────────────────────────────────
  // _buildChip(label, color) → Container with color.withValues(alpha: 0.12) background
  //   and color.withValues(alpha: 0.4) border — shows category/bodyPart/equipment tags

  // ── Summary cards ───────────────────────────────────────────────
  // _buildSummaryCard(label, value, icon) → TOTAL SETS | COMPLETED | TOTAL REPS
  //   Uses left accent border pattern for styling

  // ── Accent border cards ─────────────────────────────────────────
  // All cards with left accent use the Left Accent Border Pattern (see Architecture).
  // color.withValues(alpha: 0.12) for backgrounds — NEVER withOpacity()
}
```

---

### `lib/widgets/volume_scroll_list.dart` — Deep Dive

```dart
// ── VolumeScrollList ─────────────────────────────────────────────
// Drop-in replacement for SingleChildScrollView.
// Internally a ListView.separated with its own ScrollController.
//
// Each child is wrapped in VolumeListItem automatically.
//
// Usage:
VolumeScrollList(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
  separatorBuilder: (_, __) => const SizedBox.shrink(),  // optional, default: SizedBox(height:16)
  children: [ widget1, widget2, ... ],
)

// ── VolumeListItem ───────────────────────────────────────────────
// Use inside your own ListView.builder when you manage the ScrollController.
//
// Usage:
VolumeListItem(
  scrollController: _scrollCtrl,
  revealDelay: Duration(milliseconds: index * 80),
  child: GoalCard(...),
)

// ── Animation internals ──────────────────────────────────────────
// 1. Reveal (init):
//    _revealCtrl: AnimationController(500ms)
//    _revealFade: CurvedAnimation(Curves.easeOut)         → FadeTransition
//    _revealSlide: Tween(Offset(0, 0.28) → Offset.zero)  → SlideTransition
//    Triggered after revealDelay via Future.delayed (checks mounted before forward())
//
// 2. Volume (continuous scroll):
//    AnimatedBuilder on scrollController
//    _distanceFactor(): finds item's screen position via RenderBox.localToGlobal()
//      → 0.0 at screen centre, 1.0 at edges (normalised to 55% of half-height)
//    scale   = (1.0 - f * 0.10).clamp(0.88, 1.0)   // shrinks up to -10%
//    opacity = (1.0 - f * 0.35).clamp(0.55, 1.0)   // fades up to -35%
//    Wrapped in try-catch — returns 0.0 on any error (safe fallback)
//
// SizedBox with GlobalKey on the inner child keeps the subtree stable
// across AnimatedBuilder rebuilds so localToGlobal stays accurate.
```

---

### `lib/widgets/reveal_on_scroll.dart` — Legacy

```dart
// Simpler one-shot reveal animation (no volume/scroll effect).
// DEPRECATED — use VolumeScrollList / VolumeListItem instead.
// Still present for backwards compatibility.
//
// Usage (old):
RevealOnScroll(index: i, child: myWidget)
// Delay = (index * 70).clamp(0, 420) ms
// FadeTransition + SlideTransition (Offset(0, 0.28) → Offset.zero), 420ms easeOutCubic
```

---

### `lib/widgets/staggered_list.dart` — Legacy

```dart
// Staggered Column animation — all children animate in sequence.
// DEPRECATED — use VolumeScrollList / VolumeListItem instead.
//
// Single AnimationController spans the total duration of all items.
// Each item gets an Interval-based fade + translate animation.
// Triggered via WidgetsBinding.instance.addPostFrameCallback.
//
// Usage (old):
StaggeredList(
  staggerDelay: const Duration(milliseconds: 70),
  itemDuration: const Duration(milliseconds: 600),
  children: [ widget1, widget2, ... ],
)
```

---
---

## 👤 Nabeel — Nutrition + Progress + Goals

**Responsibility:** Meal logging screen, progress tracking screen (weight charts + body measurements), goals screen, and the supporting widgets (macro bars, goal cards).

### Files Owned

| File | Role |
|------|------|
| `lib/screens/meal_log_screen.dart` | Meal sections, macro circles, add/edit/delete meal dialog |
| `lib/screens/progress_screen.dart` | Weight trend chart with period filter, body measurements |
| `lib/screens/goals_screen.dart` | Goal cards list, add/edit/delete goal dialogs |
| `lib/widgets/macro_progress_bar.dart` | Animated horizontal macro progress bars |
| `lib/widgets/goal_card.dart` | Goal card widget with left accent strip and progress bar |

---

### `lib/screens/meal_log_screen.dart` — Structure

```dart
class MealLogScreen extends StatefulWidget { ... }

class _MealLogScreenState extends State<MealLogScreen> with SingleTickerProviderStateMixin {
  // FAB pulse animation
  late AnimationController _fabController;   // 1200ms, repeat(reverse: true)
  late Animation<double>   _fabAnimation;    // Tween(1.0 → 1.08) → ScaleTransition on FAB

  // ── Meal dialog (add + edit) ──────────────────────────────────
  void _showMealDialog(FitnessProvider provider, {Meal? meal}) async {
    // Fields: name, calories, protein, carbs, fat, category (Dropdown)
    // 'meal == null' → Add mode | 'meal != null' → Edit mode
    // Dialog returns Map: {"action": "save"|"delete", "meal": Meal?}
    //
    // On result:
    //   "delete" → provider.deleteMeal(meal!)
    //   "save" + meal == null → provider.addMeal(result["meal"] as Meal)
    //   "save" + meal != null → provider.editMeal(meal, result["meal"] as Meal)
    //
    // IMPORTANT: DropdownButtonFormField uses 'initialValue:' NOT 'value:'
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () => _showMealDialog(Provider.of<FitnessProvider>(context, listen: false)),
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) => VolumeScrollList(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          separatorBuilder: (_, __) => const SizedBox.shrink(),
          children: [
            // ── Macro summary circles ─────────────────────────────
            Container(child: Row(children: [
              CircularProgressWidget(progress: provider.totalCalories / 2000, color: AppColors.accentRed, label: 'CALORIES', ...),
              CircularProgressWidget(progress: provider.totalProtein / 150,   color: Color(0xFF4ECDC4),   label: 'PROTEIN', ...),
              CircularProgressWidget(progress: provider.totalCarbs / 220,     color: Color(0xFFFFB347),   label: 'CARBS', ...),
              CircularProgressWidget(progress: provider.totalFat / 65,        color: Color(0xFFFF6B35),   label: 'FAT', ...),
            ])),

            // ── Macro target bars ─────────────────────────────────
            Container(child: Column(children: [
              MacroProgressBar(label: 'Protein', current: provider.totalProtein, target: 150, color: Color(0xFF4ECDC4), unit: 'g'),
              MacroProgressBar(label: 'Carbs',   current: provider.totalCarbs,   target: 220, color: Color(0xFFFFB347), unit: 'g'),
              MacroProgressBar(label: 'Fat',     current: provider.totalFat,     target: 65,  color: Color(0xFFFF6B35), unit: 'g'),
            ])),

            // ── Meal sections ─────────────────────────────────────
            _buildMealSection('BREAKFAST', provider.breakfastMeals, Icons.wb_sunny_outlined, provider),
            _buildMealSection('LUNCH',     provider.lunchMeals,     Icons.wb_cloudy_outlined, provider),
            _buildMealSection('DINNER',    provider.dinnerMeals,    Icons.nights_stay_outlined, provider),
            _buildMealSection('SNACKS',    provider.snackMeals,     Icons.fastfood_outlined, provider),
          ],
        ),
      ),
    );
  }

  // ── Meal section builder ──────────────────────────────────────
  Widget _buildMealSection(String title, List<Meal> meals, IconData icon, FitnessProvider provider) {
    if (meals.isEmpty) return const SizedBox.shrink();
    // Shows section header (icon + title + total kcal) + list of _MealItem cards
    // Each _MealItem: GestureDetector → _showMealDialog(provider, meal: meal)
  }
}

// ── _MealItem (private StatelessWidget) ──────────────────────────
// Shows: meal name, macro tags (P/C/F in colour), calorie count on right
// _MacroTag: coloured text label (P: 12g, C: 58g, F: 6g)
```

---

### `lib/screens/progress_screen.dart` — Structure

```dart
class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedPeriod = 1;  // 0=1W, 1=1M, 2=3M, 3=6M
  static const List<String> _periods = ['1W', '1M', '3M', '6M'];

  // ── Period filter ─────────────────────────────────────────────
  // Maps period index to number of weekly data points to display:
  //   1W → last 2 points  |  1M → last 4 points
  //   3M → last 8 points  |  6M → all 12 points
  List<double> _filterWeightData(List<double> data) {
    if (data.isEmpty) return data;
    const counts = [2, 4, 8, 12];
    final count = counts[_selectedPeriod];
    if (data.length <= count) return data;
    return data.sublist(data.length - count);
  }

  // ── Body measurement dialog (add + edit) ─────────────────────
  void _showBodyMeasurementDialog(FitnessProvider provider, {String? key, double? value}) {
    // key == null → Add mode | key != null → Edit mode (pre-filled)
    // Add:  provider.addMeasurement(name, val)
    // Edit: provider.editMeasurement(key, name, val)
    // Delete button shown only in edit mode: provider.deleteMeasurement(key)
  }

  // ── Weight dialog (add + edit) ────────────────────────────────
  void _showWeightDialog(FitnessProvider provider, {double? weight, int? index}) {
    // weight == null → Add mode | weight != null → Edit + Delete mode
    // Add:    provider.addWeight(w)
    // Edit:   provider.editWeight(index!, w)
    // Delete: provider.deleteWeight(index!)
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitnessProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('PROGRESS'),
        actions: [
          // + button → _showWeightDialog(provider)  [adds new weight entry]
          IconButton(onPressed: () => _showWeightDialog(provider), icon: const Icon(Icons.add)),
        ],
      ),
      body: VolumeScrollList(
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        children: [

          // ── Period selector ───────────────────────────────────
          // Row of 4 animated buttons: 1W | 1M | 3M | 6M
          // Selected button: accent background + black text
          // onTap: setState(() => _selectedPeriod = index)

          // ── Weight trend chart ────────────────────────────────
          // Uses Builder to compute filtered = _filterWeightData(provider.weightData)
          // LineChart (fl_chart) with:
          //   spots: List.generate(filtered.length, (i) => FlSpot(i.toDouble(), filtered[i]))
          //   minY:  filtered.reduce(min) - 1
          //   maxY:  filtered.reduce(max) + 1
          //   Below-bar gradient: accent.withValues(alpha:0.3) → accent.withValues(alpha:0.0)
          //   x-axis labels: 'W${idx+1}' shown for even indices only
          //   gridData: hidden | borderData: hidden | dotData: const FlDotData(show: true)

          // ── Body measurements list ────────────────────────────
          // GestureDetector on each row → _showBodyMeasurementDialog(provider, key, value)
          // + IconButton in section header → _showBodyMeasurementDialog(provider)  [add mode]
          // Each row: icon container | measurement name | value + 'cm'
        ],
      ),
    );
  }
}
```

---

### `lib/screens/goals_screen.dart` — Structure

```dart
class _GoalsScreenState extends State<GoalsScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          return Column(children: [

            // ── Overall progress header ───────────────────────────
            // Left-accent-border container showing:
            //   "OVERALL PROGRESS" + "You're X% there. Keep going!"
            //   Linear progress bar (FractionallySizedBox, widthFactor: overallGoalProgress)
            //   Large accent percentage on right side

            // ── Active goals count badge ──────────────────────────
            // Row: "ACTIVE GOALS" text + Container badge with goals.length

            // ── Goals list ────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                itemCount: provider.goals.length,
                itemBuilder: (context, index) {
                  final goal = provider.goals[index];
                  return VolumeListItem(
                    scrollController: _scrollCtrl,
                    revealDelay: Duration(milliseconds: index * 80),
                    child: GoalCard(
                      goal: goal,
                      progress: (goal.current / goal.target).clamp(0.0, 1.0),
                      onEdit:   () => _showEditDialog(context, provider, index),
                      onDelete: () => _showDeleteDialog(context, provider, index),
                    ),
                  );
                },
              ),
            ),

            // ── Add Goal button ───────────────────────────────────
            // OutlinedButton (accent border) → _showAddGoalDialog(context)
          ]);
        },
      ),
    );
  }

  // ── Add goal dialog ───────────────────────────────────────────
  void _showAddGoalDialog(BuildContext context) {
    // Fields: title, current value, target value, unit
    // On save: provider.addGoal(title, current, target, unit)
    // Validation: title must not be empty, target > 0
  }

  // ── Edit goal dialog ──────────────────────────────────────────
  void _showEditDialog(BuildContext context, FitnessProvider provider, int index) {
    // Pre-fills current + target values
    // SAVE: provider.updateGoal(index, current, target)
    // DELETE (inline red button): provider.deleteGoal(index)
  }

  // ── Delete confirmation dialog ────────────────────────────────
  void _showDeleteDialog(BuildContext context, FitnessProvider provider, int index) {
    // AlertDialog with Cancel + Delete (red) buttons
    // On delete: provider.deleteGoal(index)
  }
}
```

---

### `lib/widgets/macro_progress_bar.dart`

```dart
// Animated horizontal progress bar for macro nutrients.
// Usage:
MacroProgressBar(
  label: 'Protein',
  current: provider.totalProtein,   // double
  target: 150,                      // double
  color: const Color(0xFF4ECDC4),
  unit: 'g',                        // optional, default 'g'
)

// Internals:
// AnimationController(900ms, easeOutCubic) drives width via FractionallySizedBox
// _progress = (current / target).clamp(0.0, 1.0)
// Row header: label (left) | current / target (right) as RichText
// Progress track: Container(h:6) → AnimatedBuilder → FractionallySizedBox(widthFactor: anim * _progress)
// Track background: AppColors.divider | Fill: widget.color
```

---

### `lib/widgets/goal_card.dart`

```dart
// Usage:
GoalCard(
  goal: goal,          // Goal model
  progress: 0.75,      // (goal.current / goal.target).clamp(0.0, 1.0)
  onEdit: () => ...,   // optional callback
  onDelete: () => ..., // optional — DELETE button only shown if not null
)

// Structure (uses Left Accent Border Pattern):
Container(uniform 1px border + borderRadius 16)
└── ClipRRect(radius 15)
    └── IntrinsicHeight → Row(stretch)
        ├── Container(width: 4, color: accent)       ← left accent strip
        └── Expanded → Container(surface, padding 16)
            └── Column
                ├── Row: icon container | title + subtitle | percent badge
                ├── LinearProgressIndicator (goal.progress, accent)
                └── Row: current/target text | EDIT button | DELETE button (if onDelete != null)

// Percent badge: '$percent%' using (goal.progress * 100).toStringAsFixed(0)
// EDIT: GestureDetector → onEdit callback
// DELETE: GestureDetector → onDelete callback (red border)
// Icon container: accent.withValues(alpha: 0.12) background, borderRadius 10
```

---

## Cross-Person Rules

1. **All data lives in `FitnessProvider`** — if a new field or method is needed, Abdullah adds it.
2. **All new widgets must use `AppColors` and `AppTextStyles`** — never hardcode colors or fonts.
3. **Any card with a left accent strip** must use the **Left Accent Border Pattern** from the Architecture section.
4. **Never use `.withOpacity()`** — use `.withValues(alpha: x)`.
5. **Always run `flutter analyze`** before committing — must return `No issues found!`
6. **Screens that scroll** use `VolumeScrollList` (Muneeb owns this widget; Nabeel and Abdullah consume it).
7. **Push navigation** uses `MainNavigator.slideRoute<T>(page)` (Abdullah owns this; others call it).
