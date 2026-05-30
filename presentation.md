# FitTrack - Project Presentation

## Project Overview

**FitTrack** is a Flutter-based fitness tracking application built with a dark-themed, modern UI. The app allows users to track their daily workouts, log meals and nutrition, monitor weight/body progress over time, and set fitness goals. It uses **Provider** for state management with a single `ChangeNotifier`, and all data is held in-memory (no backend or database persistence).

### Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Provider (`ChangeNotifierProvider`)
- **Charts:** fl_chart (weight trend line chart)
- **Fonts:** Google Fonts (Barlow Condensed, Inter, Barlow)
- **Sensors:** sensors_plus (step counter stub)

### App Screens
1. **Dashboard** - Home screen with daily stats overview
2. **Workout Log** - Exercise list with expandable sets
3. **Meal Log** - Nutrition tracking with macro breakdowns
4. **Progress** - Weight trend chart and body measurements
5. **Goals** - Fitness goal cards with CRUD operations

---
---

# PART 1: Abdullah - Core Foundation + Dashboard + App Shell

## Responsibility
Abdullah is responsible for the **core foundation** of the entire application. This includes the app entry point, the global state management system, the design system (colors, typography, theming), the data models used throughout the app, the navigation shell, and the **Dashboard (Home) screen** with all its widgets.

## Files Owned
| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, MaterialApp, MainNavigator, tab switching |
| `lib/theme/app_theme.dart` | AppColors, AppTextStyles, AppTheme.dark (entire design system) |
| `lib/models/models.dart` | ExerciseSet, Exercise, Meal, Goal data models |
| `lib/providers/fitness_provider.dart` | Single ChangeNotifier holding all state and CRUD methods |
| `lib/screens/dashboard_screen.dart` | Home screen with greeting, progress rings, stat cards, workout card |
| `lib/widgets/custom_bottom_nav.dart` | Bottom navigation bar with animated sliding indicator |
| `lib/widgets/circular_progress_widget.dart` | Animated circular progress rings (CustomPainter) |
| `lib/widgets/stat_card.dart` | Stat cards with progress bars and optional left accent border |

---

## 1. App Entry Point (`lib/main.dart`)

### What It Is
This is the **starting point** of the entire Flutter application. It initializes the app, sets up the system UI styling (status bar, navigation bar), wraps the entire widget tree in the Provider for state management, and defines the main navigation structure using `IndexedStack`.

### How It Works
The `main()` function ensures Flutter bindings are initialized, then configures the system UI overlays (transparent status bar, dark navigation bar) before launching the app widget. The `FitnessApp` widget wraps the entire app in a `ChangeNotifierProvider<FitnessProvider>` so that every screen can access shared state. The `MainNavigator` uses an `IndexedStack` to hold all five screens, which means **screen state is preserved** (scroll positions, animations) even when switching tabs.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

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
```

The `MainNavigator` also provides a **static route helper** (`slideRoute`) that creates consistent slide+fade page transitions for push navigation (e.g., navigating to workout detail):

```dart
static Route<T> slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (ctx, anim, secondAnim) => page,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (ctx, anim, secondAnim, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: anim, child: child),
      );
    },
  );
}
```

The navigation state is managed through the `IndexedStack` which keeps all five screens alive in memory. Tab switching is delegated to the provider:

```dart
Widget build(BuildContext context) {
  return Consumer<FitnessProvider>(
    builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: provider.selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: provider.selectedIndex,
          onTap: (index) => _onTabTap(index, provider),
        ),
      );
    },
  );
}
```

---

## 2. Design System (`lib/theme/app_theme.dart`)

### What It Is
This file defines the **entire visual identity** of the app. It contains all colors, text styles, and the complete `ThemeData` configuration. No colors or fonts are hardcoded anywhere else in the app - everything references this file.

### How It Works
The `AppColors` class defines the dark-themed color palette. The `AppTextStyles` class uses Google Fonts to define consistent typography throughout the app. The `AppTheme.dark` getter creates a complete `ThemeData` that is passed to `MaterialApp`, ensuring all Material widgets (buttons, cards, chips, dialogs) automatically inherit the correct styling.

**Color Palette:**
```dart
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0D0D);   // Page background (near-black)
  static const Color surface = Color(0xFF1A1A1A);       // Card/container background
  static const Color accent = Color(0xFFE8FF00);        // Primary accent (yellow-green)
  static const Color accentRed = Color(0xFFFF3D00);     // Secondary accent (red-orange)
  static const Color textPrimary = Color(0xFFF5F5F5);   // Headings and values
  static const Color textMuted = Color(0xFF7A7A7A);     // Labels and subtitles
  static const Color divider = Color(0xFF2C2C2C);       // Borders and separators
}
```

**Typography System (selected styles):**
```dart
class AppTextStyles {
  AppTextStyles._();

  // Large display text (e.g., user name on dashboard)
  static TextStyle displayLarge = GoogleFonts.barlowCondensed(
    fontSize: 48, fontWeight: FontWeight.w900,
    color: AppColors.textPrimary, letterSpacing: 4,
  );

  // Section headings
  static TextStyle headlineMedium = GoogleFonts.barlowCondensed(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: 2,
  );

  // Body text
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Muted labels
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
```

**Complete ThemeData** is configured with card styles, button themes, chip themes, app bar themes, etc., so all Material widgets automatically match the design:

```dart
static ThemeData get dark {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent,
      secondary: AppColors.accentRed,
      onSurface: AppColors.textPrimary,
      onPrimary: Colors.black,
      outline: AppColors.divider,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    // ... elevatedButtonTheme, outlinedButtonTheme, chipTheme, etc.
  );
}
```

---

## 3. Data Models (`lib/models/models.dart`)

### What It Is
This file defines the **four data model classes** used across the entire application: `ExerciseSet`, `Exercise`, `Meal`, and `Goal`. These are plain Dart classes that hold structured data and provide computed properties.

### How It Works
Each model is designed to be simple and focused. `ExerciseSet` uses an **immutable update pattern** via `copyWith()` - instead of mutating properties directly, a new copy is created with the changed values. The `Exercise` model has computed getters (`totalSets`, `completedSets`) that derive values from its sets list. The `Goal` model has a `progress` getter that calculates completion percentage.

```dart
class ExerciseSet {
  final int setNumber;
  final int reps;
  final double weight;
  final bool isCompleted;

  ExerciseSet({
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.isCompleted = false,
  });

  // Immutable update - never mutate directly, always create a new copy
  ExerciseSet copyWith({bool? isCompleted}) {
    return ExerciseSet(
      setNumber: setNumber, reps: reps, weight: weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Exercise {
  final String name;
  final String category;   // e.g. "Chest", "Back"
  final String bodyPart;
  final String equipment;
  List<ExerciseSet> sets;
  bool isExpanded;          // UI expansion state

  int get totalSets => sets.length;
  int get completedSets => sets.where((set) => set.isCompleted).length;
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

  // Computed progress: 0.0 to 1.0
  double get progress => (current / target).clamp(0.0, 1.0);
}
```

---

## 4. State Management (`lib/providers/fitness_provider.dart`)

### What It Is
This is the **single source of truth** for the entire application's state. `FitnessProvider` extends `ChangeNotifier` and holds all data (mock/sample data), navigation state, and all CRUD methods. Every screen reads from and writes to this provider.

### How It Works
The provider stores all mock data (steps, calories, meals, goals, weight measurements, exercises) as instance variables. When any data changes, the method calls `notifyListeners()` which triggers a rebuild of all widgets that are listening via `context.watch<FitnessProvider>()` or `Consumer<FitnessProvider>`. Derived values like `totalCalories` and `overallGoalProgress` are computed getters that calculate values on-the-fly from the raw data.

```dart
class FitnessProvider extends ChangeNotifier {
  // ── Navigation ──────────────────────────────────────────
  int selectedIndex = 0;
  void setIndex(int index) { selectedIndex = index; notifyListeners(); }

  // ── Daily Stats (mock data) ─────────────────────────────
  String userName = 'Zia';
  bool hasNotifications = true;
  int steps = 7843;           int stepsGoal = 10000;
  int caloriesBurned = 485;   int caloriesGoal = 750;
  int workoutsThisWeek = 3;   int workoutsGoal = 4;
  int activeMinutes = 142;    int activeMinutesGoal = 200;
  double waterIntake = 1.8;   double waterGoal = 2.5;

  // ── Exercises CRUD ──────────────────────────────────────
  List<Exercise> todayExercises = [ /* mock exercises */ ];

  void toggleExercise(int index) { ... notifyListeners(); }
  void toggleSet(int exerciseIndex, int setIndex) { ... notifyListeners(); }
  void addExercise(String name) { ... notifyListeners(); }
  void addSet(int exerciseIndex, int reps, double weight) { ... notifyListeners(); }
  void updateExerciseSets(Exercise exercise, List<ExerciseSet> newSets) { ... notifyListeners(); }

  // ── Meals CRUD ──────────────────────────────────────────
  List<Meal> meals = [ /* mock meals */ ];

  int    get totalCalories => meals.fold(0,   (s, m) => s + m.calories);
  double get totalProtein  => meals.fold(0.0, (s, m) => s + m.protein);
  double get totalCarbs    => meals.fold(0.0, (s, m) => s + m.carbs);
  double get totalFat      => meals.fold(0.0, (s, m) => s + m.fat);

  List<Meal> get breakfastMeals => meals.where((m) => m.category == 'Breakfast').toList();
  List<Meal> get lunchMeals     => meals.where((m) => m.category == 'Lunch').toList();
  List<Meal> get dinnerMeals    => meals.where((m) => m.category == 'Dinner').toList();
  List<Meal> get snackMeals     => meals.where((m) => m.category == 'Snack').toList();

  void addMeal(Meal meal)            { meals.add(meal);               notifyListeners(); }
  void editMeal(Meal old, Meal next) { meals[meals.indexOf(old)] = next; notifyListeners(); }
  void deleteMeal(Meal meal)         { meals.remove(meal);            notifyListeners(); }

  // ── Goals CRUD ──────────────────────────────────────────
  late List<Goal> goals;

  double get overallGoalProgress =>
      goals.isEmpty ? 0.0 : goals.fold(0.0, (s, g) => s + g.progress) / goals.length;

  void addGoal(String title, double current, double target, String unit) { ... notifyListeners(); }
  void updateGoal(int index, double current, double target)              { ... notifyListeners(); }
  void deleteGoal(int index)                                             { ... notifyListeners(); }

  // ── Weight & Body Measurements CRUD ─────────────────────
  List<double> weightData = [ 82.5, 82.1, 81.8, ... ];

  void addWeight(double weight)        { weightData.add(weight);     notifyListeners(); }
  void editWeight(int index, double w) { weightData[index] = w;      notifyListeners(); }
  void deleteWeight(int index)         { weightData.removeAt(index); notifyListeners(); }

  Map<String, double> bodyMeasurements = {
    'Chest': 102.5, 'Waist': 82.0, 'Hips': 98.5, ...
  };

  void addMeasurement(String name, double value)                  { ... notifyListeners(); }
  void editMeasurement(String old, String newName, double newVal) { ... notifyListeners(); }
  void deleteMeasurement(String name)                             { ... notifyListeners(); }
}
```

---

## 5. Dashboard Screen (`lib/screens/dashboard_screen.dart`)

### What It Is
This is the **home screen** of the app - the first thing users see. It displays a personalized greeting with the user's name, the current date, circular progress rings for steps and calories, stat cards for workouts/active minutes/water, a "Today's Workout" card showing the current workout plan, and a weekly activity summary.

### How It Works
The screen reads all its data from `FitnessProvider` via `context.watch<FitnessProvider>()`, which means it automatically rebuilds whenever any data changes. It uses `VolumeScrollList` (Muneeb's scroll animation widget) for the scrollable body, which gives each section a smooth reveal animation and a "volume dial" scroll effect.

**Greeting Section** - dynamically determines the greeting based on current time:
```dart
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'GOOD MORNING,';
  if (hour < 17) return 'GOOD AFTERNOON,';
  return 'GOOD EVENING,';
}
```

**Circular Progress Rings** - two large animated rings for Steps and Calories:
```dart
CircularProgressWidget(
  progress: provider.steps / provider.stepsGoal,  // 0.0 - 1.0
  size: 130,
  strokeWidth: 10,
  color: AppColors.accent,
  label: 'STEPS',
  value: provider.steps.toString(),
  unit: '/ ${provider.stepsGoal}',
),
```

**Stat Cards Row** - three cards showing workouts, active minutes, and water intake:
```dart
Row(
  children: [
    Expanded(child: StatCard(
      label: 'WORKOUTS', value: provider.workoutsThisWeek.toString(),
      unit: 'this week', icon: Icons.fitness_center_outlined,
      progress: provider.workoutsThisWeek / provider.workoutsGoal,
    )),
    const SizedBox(width: 10),
    Expanded(child: StatCard(
      label: 'ACTIVE MIN', value: provider.activeMinutes.toString(),
      unit: 'min', icon: Icons.timer_outlined,
      progress: provider.activeMinutes / provider.activeMinutesGoal,
    )),
    const SizedBox(width: 10),
    Expanded(child: StatCard(
      label: 'WATER', value: provider.waterIntake.toString(),
      unit: 'L', icon: Icons.water_drop_outlined,
      progress: provider.waterIntake / provider.waterGoal,
      accentLeft: true,  // enables the yellow left accent border
    )),
  ],
),
```

**Today's Workout Card** - uses the **Left Accent Border Pattern** (a 4px yellow strip on the left side). This pattern is critical because Flutter throws a runtime error when you try to use `borderRadius` with non-uniform border widths. The solution is to use an outer container with uniform borders, then an inner `ClipRRect` with a `Row` containing a 4px accent strip:

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.divider, width: 1), // uniform border
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
              child: Column(/* workout card content */),
            ),
          ),
        ],
      ),
    ),
  ),
),
```

**Weekly Summary** - a row of 7 day circles showing workout completion status:
```dart
Widget _buildWeekDay(String day, bool completed) {
  return Column(
    children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: completed ? AppColors.accent : AppColors.divider.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          completed ? Icons.check : Icons.remove,
          size: 16,
          color: completed ? Colors.black : AppColors.textMuted,
        ),
      ),
      const SizedBox(height: 4),
      Text(day, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
    ],
  );
}
```

---

## 6. Circular Progress Widget (`lib/widgets/circular_progress_widget.dart`)

### What It Is
A **reusable animated circular progress ring** widget used on the Dashboard (steps, calories) and Meal Log screen (calories, protein, carbs, fat). It draws two arcs using `CustomPainter`: a background arc (gray) and a foreground arc (colored) that animates from 0 to the target progress value.

### How It Works
When the widget first builds, an `AnimationController` runs for 1200ms with an `easeOutCubic` curve, driving the progress arc from 0 to its final value. The `CustomPainter` class `_CircularProgressPainter` calculates the arc sweep angle as `2*pi * progress` and draws it starting from the top (-pi/2). When the progress value changes (e.g., data updates), `didUpdateWidget` resets and replays the animation.

```dart
class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _controller.reset();
      _controller.forward();  // re-animate when data changes
    }
  }
}
```

The `CustomPainter` draws two arcs on the canvas:

```dart
class _CircularProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    const startAngle = -math.pi / 2;  // start from top
    const fullSweep = 2 * math.pi;

    // Background arc (full circle, gray)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, fullSweep, false, bgPaint);

    // Foreground arc (partial, colored)
    if (progress > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, fullSweep * progress.clamp(0.0, 1.0), false, fgPaint);
    }
  }
}
```

---

## 7. Custom Bottom Navigation (`lib/widgets/custom_bottom_nav.dart`)

### What It Is
A **custom bottom navigation bar** with 5 tabs (Home, Workout, Meals, Progress, Goals) featuring a sliding accent indicator that smoothly animates between tabs.

### How It Works
The indicator is an `AnimatedPositioned` widget that slides horizontally to align with the selected tab. Its position is calculated as `selectedIndex * itemWidth`. The animation uses a 250ms `easeOut` curve for smooth transitions. Active tab icons and labels are colored with the accent color, while inactive ones use the muted color.

```dart
// 5 tabs: Home, Workout, Meals, Progress, Goals
// Sliding accent bar:
//   AnimatedPositioned(duration: 250ms, curve: Curves.easeOut)
//   left = selectedIndex * itemWidth
//   top = 0, height = 2px, color = AppColors.accent
// Active: AppColors.accent | Inactive: AppColors.textMuted
// Bar height: 72px | Border top: AppColors.divider 1px
```

---
---

# PART 2: Muneeb - Workout Features + Scroll Animation System

## Responsibility
Muneeb is responsible for all **workout-related screens** (the exercise list and the detailed exercise view with set logging), as well as the **primary scroll animation system** (`VolumeScrollList`) that is used by every screen in the app for smooth, polished scroll effects.

## Files Owned
| File | Purpose |
|------|---------|
| `lib/screens/workout_log_screen.dart` | Expandable exercise list with add exercise/set dialogs |
| `lib/screens/workout_detail_screen.dart` | Full exercise detail page with set logging and Hero animation |
| `lib/widgets/volume_scroll_list.dart` | Primary scroll animation system (reveal + volume effects) |
| `lib/widgets/reveal_on_scroll.dart` | Legacy reveal animation widget (superseded by VolumeScrollList) |
| `lib/widgets/staggered_list.dart` | Legacy stagger animation widget (superseded by VolumeScrollList) |

---

## 1. Workout Log Screen (`lib/screens/workout_log_screen.dart`)

### What It Is
This is the main **workout tracking screen** where users see all their exercises for the day. Each exercise is displayed as an expandable card showing its sets (reps, weight, completion status). Users can add new exercises, add sets to existing exercises, toggle set completion, and delete sets.

### How It Works
The screen is a `StatelessWidget` that reads exercise data from `FitnessProvider`. At the top, a **daily stats summary card** shows steps, calories, workouts, and water intake with progress bars. Below that, a `ListView.builder` renders each exercise as an `ExpansionTile` wrapped in a `Card`. Each expansion tile shows the exercise's sets as `ListTile` items with checkboxes. A `FloatingActionButton` opens the "Add Exercise" dialog.

**Daily Stats Summary:**
```dart
Card(
  color: Colors.grey[900],
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      children: [
        _statWidget("Steps", provider.steps.toDouble(), provider.stepsGoal.toDouble()),
        _statWidget("Calories", provider.caloriesBurned.toDouble(), provider.caloriesGoal.toDouble()),
        _statWidget("Workouts", provider.workoutsThisWeek.toDouble(), 7.0),
        _statWidget("Water", provider.waterIntake, 2.5, isDouble: true),
      ],
    ),
  ),
),
```

**Expandable Exercise List** - each exercise is an `ExpansionTile` with sets listed inside:
```dart
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
        subtitle: Text("${exercise.category} • ${exercise.bodyPart} • ${exercise.equipment}"),
        children: [
          // Sets with checkboxes
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
          // Add Set button inside expansion
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
```

**Add Exercise Dialog** - a simple text input dialog that creates a new exercise:
```dart
void _showAddExerciseDialog(BuildContext context, FitnessProvider provider) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Add New Exercise"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Exercise Name"),
      ),
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
```

**Add Set Dialog** - collects reps and weight for a new set:
```dart
void _showAddSetDialog(BuildContext context, FitnessProvider provider, int exerciseIndex) async {
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Add Set"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: repsController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Reps")),
        TextField(controller: weightController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Weight (kg)")),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            final reps = int.tryParse(repsController.text.trim()) ?? 0;
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
```

---

## 2. Workout Detail Screen (`lib/screens/workout_detail_screen.dart`)

### What It Is
A **detailed view for a single exercise** showing its name, category tags, a structured set table with LOG/DONE buttons, summary statistics (total sets, completed, total reps), and an "Add Set" button. This screen is navigated to from the Workout Log screen via `MainNavigator.slideRoute()`.

### How It Works
This is a `StatefulWidget` that takes an `Exercise` object as a parameter. On init, it creates a **local mutable copy** of the exercise's sets (`_sets = List.from(widget.exercise.sets)`). All set modifications (toggling completion, adding sets) update this local copy via `setState()` and then sync back to the provider via `provider.updateExerciseSets()`. The screen features a Hero animation on the exercise name for a smooth transition effect.

**Exercise Header with Category Chips:**
```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.divider, width: 1),
  ),
  child: Row(
    children: [
      // Body silhouette placeholder (containers arranged as head, torso, legs)
      Container(width: 80, height: 80, ...),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: exercise.name,
              child: Material(
                color: Colors.transparent,
                child: Text(exercise.name.toUpperCase(), ...),
              ),
            ),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _buildChip(exercise.category, categoryColor),
              _buildChip(exercise.bodyPart, AppColors.textMuted),
              _buildChip(exercise.equipment, AppColors.textMuted),
            ]),
          ],
        ),
      ),
    ],
  ),
),
```

**Category Color System** - each muscle group gets a distinct color:
```dart
Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'chest':     return const Color(0xFFFF6B35);
    case 'back':      return const Color(0xFF4ECDC4);
    case 'shoulders': return const Color(0xFF9B59B6);
    case 'hips':      return const Color(0xFFE74C3C);
    case 'aerobic':   return const Color(0xFF2ECC71);
    default:          return AppColors.accent;
  }
}
```

**Set Table with LOG/DONE Toggle** - each set row shows set number, reps, weight, and a toggleable LOG/DONE button:
```dart
...List.generate(_sets.length, (index) {
  final set = _sets[index];
  return Container(
    color: set.isCompleted ? AppColors.accent.withValues(alpha: 0.05) : Colors.transparent,
    child: Row(
      children: [
        SizedBox(width: 50, child: Text('${set.setNumber}', ...)),
        Expanded(child: Text('${set.reps}', textAlign: TextAlign.center, ...)),
        Expanded(child: Text(set.weight > 0 ? '${set.weight} kg' : 'BW', ...)),
        GestureDetector(
          onTap: () {
            setState(() {
              _sets[index] = ExerciseSet(
                setNumber: set.setNumber, reps: set.reps, weight: set.weight,
                isCompleted: !set.isCompleted,
              );
            });
            context.read<FitnessProvider>().updateExerciseSets(widget.exercise, _sets);
          },
          child: Container(
            decoration: BoxDecoration(
              color: set.isCompleted ? AppColors.accent : Colors.transparent,
              border: Border.all(
                color: set.isCompleted ? AppColors.accent : AppColors.divider,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(set.isCompleted ? 'DONE' : 'LOG', ...),
          ),
        ),
      ],
    ),
  );
}),
```

**Add Set** - uses the last set's reps/weight as defaults for convenience:
```dart
OutlinedButton(
  onPressed: () {
    setState(() {
      _sets.add(ExerciseSet(
        setNumber: _sets.length + 1,
        reps: _sets.isNotEmpty ? _sets.last.reps : 10,
        weight: _sets.isNotEmpty ? _sets.last.weight : 0,
      ));
    });
    context.read<FitnessProvider>().updateExerciseSets(widget.exercise, _sets);
  },
  child: Text('+ ADD SET', ...),
),
```

**Summary Cards** - three stat cards showing totals:
```dart
Row(children: [
  Expanded(child: _buildSummaryCard('TOTAL SETS', '${_sets.length}', Icons.layers_outlined)),
  Expanded(child: _buildSummaryCard('COMPLETED',
      '${_sets.where((s) => s.isCompleted).length}', Icons.check_circle_outline)),
  Expanded(child: _buildSummaryCard('TOTAL REPS',
      '${_sets.fold(0, (sum, s) => sum + s.reps)}', Icons.repeat)),
]),
```

---

## 3. Volume Scroll List (`lib/widgets/volume_scroll_list.dart`)

### What It Is
The **primary scroll animation system** used across the entire app. It is a drop-in replacement for `SingleChildScrollView` that combines two animation effects: (1) a GSAP-style staggered reveal animation when items first appear, and (2) a continuous "volume/drum-wheel" effect where items far from the screen centre shrink and fade while scrolling.

### How It Works
`VolumeScrollList` is a wrapper that internally uses `ListView.separated` with its own `ScrollController`. It automatically wraps each child in a `VolumeListItem`. For screens that manage their own `ListView.builder` (like Goals screen), `VolumeListItem` can be used directly.

**VolumeScrollList (drop-in wrapper):**
```dart
class VolumeScrollList extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;
}

class _VolumeScrollListState extends State<VolumeScrollList> {
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _controller,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemCount: widget.children.length,
      separatorBuilder: widget.separatorBuilder ?? (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => VolumeListItem(
        key: ValueKey(index),
        scrollController: _controller,
        revealDelay: Duration(milliseconds: (index * 65).clamp(0, 400)),
        child: widget.children[index],
      ),
    );
  }
}
```

**VolumeListItem Animation - Two Combined Effects:**

**Effect 1: GSAP-Style Reveal (on first build)**
Each item slides up from `Offset(0, 0.28)` and fades in over 500ms with an `easeOutCubic` curve. Items are staggered by `index * 65ms` (clamped at 400ms max delay):

```dart
// Reveal animation setup
_revealCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
_revealFade = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut);
_revealSlide = Tween<Offset>(
  begin: const Offset(0, 0.28),
  end: Offset.zero,
).animate(CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOutCubic));

// Trigger after staggered delay
Future.delayed(widget.revealDelay, () {
  if (mounted) _revealCtrl.forward();
});
```

**Effect 2: Volume/Drum-Wheel (continuous while scrolling)**
An `AnimatedBuilder` listens to the scroll controller. For each scroll event, it calculates the item's distance from the screen centre using `RenderBox.localToGlobal()`. Items at the centre appear at full size/opacity, while items near the edges shrink up to 10% and fade up to 35%:

```dart
double _distanceFactor() {
  final ctx = _key.currentContext;
  if (ctx == null) return 0.0;
  try {
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 0.0;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    final itemCentre = pos.dy + box.size.height / 2;
    final screenCentre = screenH / 2;
    final dist = (itemCentre - screenCentre).abs();
    return (dist / (screenH * 0.55)).clamp(0.0, 1.0);  // 0 = centre, 1 = edge
  } catch (_) {
    return 0.0;  // safe fallback
  }
}

// Applied in build:
final f = _distanceFactor();
final scale = (1.0 - f * 0.10).clamp(0.88, 1.0);    // shrinks up to 10%
final opacity = (1.0 - f * 0.35).clamp(0.55, 1.0);   // fades up to 35%
return Transform.scale(
  scale: scale,
  child: Opacity(opacity: opacity, child: child),
);
```

**Both effects combined** in the build method:
```dart
@override
Widget build(BuildContext context) {
  return FadeTransition(
    opacity: _revealFade,
    child: SlideTransition(
      position: _revealSlide,
      child: AnimatedBuilder(
        animation: widget.scrollController,
        child: SizedBox(key: _key, child: widget.child),  // stable subtree
        builder: (ctx, child) {
          final f = _distanceFactor();
          final scale = (1.0 - f * 0.10).clamp(0.88, 1.0);
          final opacity = (1.0 - f * 0.35).clamp(0.55, 1.0);
          return Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity, child: child),
          );
        },
      ),
    ),
  );
}
```

---

## 4. Legacy Widgets (Superseded)

### `lib/widgets/reveal_on_scroll.dart`
A simpler one-shot reveal animation (no volume effect). Each item fades in and slides up with a delay based on its index. **Deprecated** - replaced by `VolumeScrollList` which adds the volume/drum-wheel scroll effect on top of the reveal.

```dart
// Usage (old):
RevealOnScroll(index: i, child: myWidget)
// Delay = (index * 70).clamp(0, 420) ms
// FadeTransition + SlideTransition (Offset(0, 0.28) -> zero), 420ms easeOutCubic
```

### `lib/widgets/staggered_list.dart`
A staggered column animation where all children animate in sequence using a single `AnimationController` that spans the total duration. Each item gets an `Interval`-based fade + translate animation. **Deprecated** - replaced by `VolumeScrollList`.

```dart
// Usage (old):
StaggeredList(
  staggerDelay: const Duration(milliseconds: 70),
  itemDuration: const Duration(milliseconds: 600),
  children: [ widget1, widget2, ... ],
)
```

---
---

# PART 3: Nabeel - Nutrition + Progress + Goals

## Responsibility
Nabeel is responsible for the **Meal Log screen** (nutrition tracking with macro breakdowns), the **Progress screen** (weight trend chart and body measurements), the **Goals screen** (goal cards with CRUD operations), and the supporting widgets (`MacroProgressBar` and `GoalCard`).

## Files Owned
| File | Purpose |
|------|---------|
| `lib/screens/meal_log_screen.dart` | Meal sections with macro circles, add/edit/delete meal dialog |
| `lib/screens/progress_screen.dart` | Weight trend chart with period filter, body measurements |
| `lib/screens/goals_screen.dart` | Goal cards list with add/edit/delete goal dialogs |
| `lib/widgets/macro_progress_bar.dart` | Animated horizontal progress bars for macro nutrients |
| `lib/widgets/goal_card.dart` | Goal card widget with left accent strip and progress bar |

---

## 1. Meal Log Screen (`lib/screens/meal_log_screen.dart`)

### What It Is
The **nutrition tracking screen** where users can view their daily macro intake through circular progress rings and horizontal progress bars, and manage individual meals organized by category (Breakfast, Lunch, Dinner, Snacks). Users can add new meals, edit existing meals, and delete meals through a dialog system.

### How It Works
This is a `StatefulWidget` with `SingleTickerProviderStateMixin` for the FAB pulse animation. It uses a `Consumer<FitnessProvider>` to rebuild whenever meal data changes. The body is a `VolumeScrollList` containing macro summary circles, macro target bars, and meal sections. The `FloatingActionButton` has a continuous pulse animation (scaling between 1.0x and 1.08x) to draw attention.

**FAB Pulse Animation:**
```dart
class _MealLogScreenState extends State<MealLogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    _fabController.repeat(reverse: true);  // continuous pulsing
  }
}

// Used in build:
floatingActionButton: ScaleTransition(
  scale: _fabAnimation,
  child: FloatingActionButton(
    onPressed: () => _showMealDialog(provider),
    backgroundColor: AppColors.accent,
    child: const Icon(Icons.add, color: Colors.black, size: 28),
  ),
),
```

**Macro Summary Circles** - four circular progress widgets showing daily nutrition progress:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    CircularProgressWidget(
      progress: provider.totalCalories / 2000,
      size: 80, strokeWidth: 7,
      color: AppColors.accentRed,
      label: 'CALORIES', value: '${provider.totalCalories}', unit: 'kcal',
    ),
    CircularProgressWidget(
      progress: provider.totalProtein / 150,
      size: 80, strokeWidth: 7,
      color: const Color(0xFF4ECDC4),
      label: 'PROTEIN', value: '${provider.totalProtein.toInt()}', unit: 'g',
    ),
    CircularProgressWidget(
      progress: provider.totalCarbs / 220,
      size: 80, strokeWidth: 7,
      color: const Color(0xFFFFB347),
      label: 'CARBS', value: '${provider.totalCarbs.toInt()}', unit: 'g',
    ),
    CircularProgressWidget(
      progress: provider.totalFat / 65,
      size: 80, strokeWidth: 7,
      color: const Color(0xFFFF6B35),
      label: 'FAT', value: '${provider.totalFat.toInt()}', unit: 'g',
    ),
  ],
),
```

**Macro Target Progress Bars** - horizontal animated bars showing progress toward daily targets:
```dart
MacroProgressBar(label: 'Protein', current: provider.totalProtein, target: 150,
    color: const Color(0xFF4ECDC4), unit: 'g'),
MacroProgressBar(label: 'Carbs', current: provider.totalCarbs, target: 220,
    color: const Color(0xFFFFB347), unit: 'g'),
MacroProgressBar(label: 'Fat', current: provider.totalFat, target: 65,
    color: const Color(0xFFFF6B35), unit: 'g'),
```

**Meal Dialog (Add + Edit + Delete)** - a single dialog that handles all three operations depending on whether a `meal` parameter is passed:
```dart
void _showMealDialog(FitnessProvider provider, {Meal? meal}) async {
  final nameController = TextEditingController(text: meal?.name ?? '');
  final caloriesController = TextEditingController(text: meal?.calories.toString() ?? '');
  // ... protein, carbs, fat controllers
  String category = meal?.category ?? 'Breakfast';

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(meal == null ? 'Add New Meal' : 'Edit Meal'),
        content: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Meal Name')),
            TextField(controller: caloriesController, keyboardType: TextInputType.number, ...),
            // ... protein, carbs, fat fields
            DropdownButtonFormField<String>(
              initialValue: category,  // IMPORTANT: uses initialValue, NOT value (deprecated)
              items: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map(...).toList(),
              onChanged: (v) => category = v ?? 'Breakfast',
            ),
          ]),
        ),
        actions: [
          if (meal != null)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, {"action": "delete"}),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newMeal = Meal(name: nameController.text, category: category, ...);
              Navigator.pop(dialogContext, {"action": "save", "meal": newMeal});
            },
            child: Text(meal == null ? 'Add Meal' : 'Save Changes'),
          ),
        ],
      );
    },
  );

  // Handle result
  if (result != null && mounted) {
    if (result["action"] == "delete") provider.deleteMeal(meal!);
    else if (result["action"] == "save") {
      if (meal == null) provider.addMeal(result["meal"] as Meal);
      else provider.editMeal(meal, result["meal"] as Meal);
    }
  }
}
```

**Meal Sections** - meals grouped by category with section headers and calorie totals:
```dart
Widget _buildMealSection(String title, List<Meal> meals, IconData icon, FitnessProvider provider) {
  if (meals.isEmpty) return const SizedBox.shrink();
  final sectionCalories = meals.fold(0, (sum, m) => sum + m.calories);

  return Column(children: [
    Row(children: [
      Icon(icon, size: 16, color: AppColors.accent),
      const SizedBox(width: 8),
      Text(title, ...),
      const Spacer(),
      Text('$sectionCalories kcal', ...),
    ]),
    ...meals.map((meal) => GestureDetector(
      onTap: () => _showMealDialog(provider, meal: meal),  // tap to edit
      child: _MealItem(meal: meal),
    )),
  ]);
}
```

**Meal Item Card** - individual meal display with coloured macro tags:
```dart
class _MealItem extends StatelessWidget {
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(children: [
        Expanded(child: Column(children: [
          Text(meal.name, ...),
          Row(children: [
            _MacroTag('P: ${meal.protein.toInt()}g', const Color(0xFF4ECDC4)),
            _MacroTag('C: ${meal.carbs.toInt()}g', const Color(0xFFFFB347)),
            _MacroTag('F: ${meal.fat.toInt()}g', const Color(0xFFFF6B35)),
          ]),
        ])),
        Column(children: [
          Text('${meal.calories}', ...),  // large calorie number
          Text('kcal', ...),
        ]),
      ]),
    );
  }
}
```

---

## 2. Progress Screen (`lib/screens/progress_screen.dart`)

### What It Is
The **progress tracking screen** that visualizes the user's weight trend over time using an interactive line chart, allows filtering by time period (1W, 1M, 3M, 6M), and displays body measurements (Chest, Waist, Hips, etc.) with full CRUD support.

### How It Works
This is a `StatefulWidget` that manages a `_selectedPeriod` state for the chart filter. It uses `context.watch<FitnessProvider>()` for reactive data updates and `VolumeScrollList` for the scrollable body. The weight chart uses `fl_chart`'s `LineChart` widget to render a curved line with a gradient fill below it.

**Period Filter** - maps period selections to data point counts:
```dart
int _selectedPeriod = 1; // 0=1W, 1=1M, 2=3M, 3=6M
static const List<String> _periods = ['1W', '1M', '3M', '6M'];

List<double> _filterWeightData(List<double> data) {
  if (data.isEmpty) return data;
  const counts = [2, 4, 8, 12]; // number of weekly data points per period
  final count = counts[_selectedPeriod];
  if (data.length <= count) return data;
  return data.sublist(data.length - count);  // take last N points
}
```

**Animated Period Selector Buttons:**
```dart
Row(
  children: List.generate(_periods.length, (index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(_periods[index],
            style: GoogleFonts.barlow(
              color: isSelected ? Colors.black : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }),
),
```

**Weight Trend Chart (fl_chart):**
```dart
Builder(builder: (context) {
  final filtered = _filterWeightData(provider.weightData);
  return LineChart(
    LineChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx % 2 != 0) return const SizedBox.shrink(); // show every other label
              return Text('W${idx + 1}', ...);
            },
          ),
        ),
        // left, right, top titles hidden
      ),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(filtered.length,
              (i) => FlSpot(i.toDouble(), filtered[i])),
          isCurved: true,
          color: AppColors.accent,
          barWidth: 2.5,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.accent.withValues(alpha: 0.3),  // gradient fill
                AppColors.accent.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      minY: filtered.reduce((a, b) => a < b ? a : b) - 1,
      maxY: filtered.reduce((a, b) => a > b ? a : b) + 1,
    ),
  );
}),
```

**Weight Change Badge** - shows total weight change with an up/down arrow:
```dart
if (provider.weightData.length > 1)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(children: [
      Icon(
        provider.weightData.last < provider.weightData.first
            ? Icons.arrow_downward : Icons.arrow_upward,
        size: 12, color: const Color(0xFF2ECC71),
      ),
      Text(
        '${(provider.weightData.last - provider.weightData.first).toStringAsFixed(1)} kg',
        ...
      ),
    ]),
  ),
```

**Body Measurements List** - tappable rows that open edit/add dialogs:
```dart
...provider.bodyMeasurements.entries.map((measurement) {
  return GestureDetector(
    onTap: () => _showBodyMeasurementDialog(provider,
        key: measurement.key, value: measurement.value),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(  // icon container
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.straighten_outlined, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Text(measurement.key, ...),  // measurement name
        const Spacer(),
        RichText(text: TextSpan(children: [
          TextSpan(text: '${measurement.value}', ...),  // value
          TextSpan(text: ' cm', ...),                    // unit
        ])),
      ]),
    ),
  );
}),
```

**Body Measurement Dialog (Add + Edit + Delete):**
```dart
void _showBodyMeasurementDialog(FitnessProvider provider, {String? key, double? value}) {
  final nameController = TextEditingController(text: key ?? '');
  final valueController = TextEditingController(text: value?.toString() ?? '');

  showDialog(context: context, builder: (_) {
    return AlertDialog(
      title: Text(key == null ? 'Add Measurement' : 'Edit Measurement'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Measurement Name')),
        TextField(controller: valueController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Value (cm)')),
      ]),
      actions: [
        if (key != null)
          TextButton(
            onPressed: () { provider.deleteMeasurement(key); Navigator.pop(context); },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            final val = double.tryParse(valueController.text) ?? 0.0;
            if (name.isEmpty) return;
            if (key == null) provider.addMeasurement(name, val);
            else provider.editMeasurement(key, name, val);
            Navigator.pop(context);
          },
          child: Text(key == null ? 'Add' : 'Save'),
        ),
      ],
    );
  });
}
```

---

## 3. Goals Screen (`lib/screens/goals_screen.dart`)

### What It Is
The **goals management screen** where users can view their fitness goals as cards with progress bars, see overall progress across all goals, and perform full CRUD operations (add, edit, delete goals). It features a left-accent-bordered overall progress header, a goals count badge, and a scrollable list of `GoalCard` widgets with volume scroll animations.

### How It Works
This is a `StatefulWidget` that manages its own `ScrollController` for the `VolumeListItem` scroll effects. It uses `Consumer<FitnessProvider>` to rebuild on data changes. The overall progress is calculated as the average of all individual goal progress values. Goals are displayed in a `ListView.builder` with each item wrapped in `VolumeListItem` for staggered reveal and volume effects. The add/edit dialogs use `showModalBottomSheet` for a modern mobile UX pattern.

**Overall Progress Header** (with left accent border):
```dart
Container(
  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: const Border(
      top: BorderSide(color: AppColors.divider, width: 1),
      right: BorderSide(color: AppColors.divider, width: 1),
      bottom: BorderSide(color: AppColors.divider, width: 1),
      left: BorderSide(color: AppColors.accent, width: 4),  // accent left border
    ),
  ),
  child: Row(children: [
    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OVERALL PROGRESS', ...),
        Text('You\'re $overallPercent% there. Keep going!', ...),
        // Linear progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: provider.overallGoalProgress,
            child: Container(
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
      ],
    )),
    Text('$overallPercent%',
      style: GoogleFonts.barlowCondensed(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.accent),
    ),
  ]),
),
```

**Goals List with Volume Scroll Animation:**
```dart
Expanded(
  child: ListView.builder(
    controller: _scrollCtrl,
    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    itemCount: provider.goals.length,
    itemBuilder: (context, index) {
      final goal = provider.goals[index];
      final progress = (goal.current / goal.target).clamp(0.0, 1.0);

      return VolumeListItem(
        scrollController: _scrollCtrl,
        revealDelay: Duration(milliseconds: index * 80),  // staggered reveal
        child: GoalCard(
          goal: goal,
          progress: progress,
          onEdit: () => _showEditDialog(context, provider, index),
          onDelete: () => _showDeleteDialog(context, provider, index),
        ),
      );
    },
  ),
),
```

**Add Goal Bottom Sheet:**
```dart
void _showAddGoalDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final currentCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  final unitCtrl = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('ADD NEW GOAL', ...),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Goal Title')),
          TextField(controller: currentCtrl, keyboardType: TextInputType.number, ...),
          TextField(controller: targetCtrl, keyboardType: TextInputType.number, ...),
          TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (kg, cm, etc.)')),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<FitnessProvider>();
              if (title.isNotEmpty && target > 0) {
                provider.addGoal(title, current, target, unit);
                Navigator.pop(ctx);
              }
            },
            child: Text('ADD GOAL', ...),
          ),
        ]),
      );
    },
  );
}
```

**Edit Goal Bottom Sheet** (with inline delete button):
```dart
void _showEditDialog(BuildContext context, FitnessProvider provider, int index) {
  final goal = provider.goals[index];
  final currentCtrl = TextEditingController(text: goal.current.toString());
  final targetCtrl = TextEditingController(text: goal.target.toString());

  showModalBottomSheet(..., builder: (ctx) {
    return Column(children: [
      Row(children: [
        Text('EDIT GOAL', ...),
        const Spacer(),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
      ]),
      TextField(controller: currentCtrl, ...),
      TextField(controller: targetCtrl, ...),
      Row(children: [
        Expanded(child: ElevatedButton(
          onPressed: () {
            provider.updateGoal(index, current, target);
            Navigator.pop(ctx);
          },
          child: Text('SAVE CHANGES', ...),
        )),
        Expanded(child: OutlinedButton(
          onPressed: () {
            provider.deleteGoal(index);
            Navigator.pop(ctx);
          },
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
          child: Text('DELETE', style: TextStyle(color: Colors.red)),
        )),
      ]),
    ]);
  });
}
```

---

## 4. Macro Progress Bar (`lib/widgets/macro_progress_bar.dart`)

### What It Is
A **reusable animated horizontal progress bar** widget used in the Meal Log screen to show progress toward daily macro nutrient targets (Protein, Carbs, Fat). Each bar has a label, current/target values, and a colored fill that animates from 0 to the actual progress.

### How It Works
This widget uses an `AnimationController` (900ms, `easeOutCubic`) that drives a `FractionallySizedBox` to animate the bar width from 0 to the progress value. The progress is calculated as `(current / target).clamp(0.0, 1.0)`. The header row shows the label on the left and current/target values on the right.

```dart
class MacroProgressBar extends StatefulWidget {
  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;
}

class _MacroProgressBarState extends State<MacroProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  double get _progress => (widget.current / widget.target).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header: label (left) | current/target (right)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.label, ...),
          RichText(text: TextSpan(children: [
            TextSpan(text: '${widget.current.toInt()}', ...),
            TextSpan(text: ' / ${widget.target.toInt()}${widget.unit}', ...),
          ])),
        ],
      ),
      // Animated progress bar
      Container(
        height: 6,
        decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(3)),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _animation.value * _progress,  // animated width
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
```

---

## 5. Goal Card (`lib/widgets/goal_card.dart`)

### What It Is
A **reusable goal card widget** that displays a single fitness goal with an icon, title, subtitle, progress percentage badge, a linear progress bar, current/target values, and optional Edit/Delete action buttons. It uses the **Left Accent Border Pattern** for its visual styling.

### How It Works
The card receives a `Goal` model and a `progress` value. It uses the Left Accent Border Pattern: an outer `Container` with uniform 1px borders and borderRadius, containing a `ClipRRect` with a `Row` that has a 4px accent strip on the left and the card content on the right. The progress percentage is shown as a badge in the top-right corner. Edit and Delete buttons are `GestureDetector` widgets with outlined styling.

```dart
class GoalCard extends StatelessWidget {
  final Goal goal;
  final double progress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
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
                  child: Column(children: [
                    // Row: icon | title + subtitle | percentage badge
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(goal.icon, size: 20, color: AppColors.accent),
                      ),
                      Expanded(child: Column(children: [
                        Text(goal.title, ...),
                        Text(goal.subtitle, ...),
                      ])),
                      Container(  // percentage badge
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.accent, width: 1),
                        ),
                        child: Text('$percent%', ...),
                      ),
                    ]),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 6,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),

                    // Row: current/target | EDIT | DELETE
                    Row(children: [
                      RichText(text: TextSpan(children: [
                        TextSpan(text: '${goal.current}', ...),
                        TextSpan(text: ' / ${goal.target} ${goal.unit}', ...),
                      ])),
                      GestureDetector(onTap: onEdit, child: Container(
                        decoration: BoxDecoration(border: Border.all(color: AppColors.accent)),
                        child: Text('EDIT', ...),
                      )),
                      if (onDelete != null)
                        GestureDetector(onTap: onDelete, child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                          child: Text('DELETE', style: TextStyle(color: Colors.red)),
                        )),
                    ]),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---
---

# Cross-Team Architecture Rules

1. **All data lives in `FitnessProvider`** - Abdullah owns the provider; if a new field or method is needed, Abdullah adds it to `fitness_provider.dart`.
2. **All widgets use `AppColors` and `AppTextStyles`** - never hardcode colors or font styles inline.
3. **Any card with a left accent strip** must use the **Left Accent Border Pattern** (outer uniform border + inner ClipRRect + Row with accent strip).
4. **Never use `.withOpacity()`** - always use `.withValues(alpha: x)` instead.
5. **Always run `flutter analyze`** before committing - must return "No issues found!"
6. **Screens that scroll** use `VolumeScrollList` (Muneeb's widget; Abdullah and Nabeel consume it).
7. **Push navigation** uses `MainNavigator.slideRoute<T>(page)` (Abdullah's helper; others call it).
