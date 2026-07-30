import 'package:flutter/material.dart';
import '../models/models.dart';

class FitnessProvider extends ChangeNotifier {
  int selectedIndex = 0;

  // -------------------------
  // Daily stats
  // -------------------------
  String userName = 'Zia';
  bool hasNotifications = true;
  int workoutsGoal = 4;
  int activeMinutesGoal = 200;
  double waterGoal = 2.5;
  int todayWorkoutDuration = 45;
  String todayWorkoutName = 'UPPER BODY POWER';
  String todayWorkoutFocus = 'CHEST & BACK';

  List<Map<String, dynamic>> weeklyStatus = [
    {'day': 'Mon', 'completed': true},
    {'day': 'Tue', 'completed': true},
    {'day': 'Wed', 'completed': false},
    {'day': 'Thu', 'completed': true},
    {'day': 'Fri', 'completed': false},
    {'day': 'Sat', 'completed': false},
    {'day': 'Sun', 'completed': false},
  ];

  int steps = 7843;
  int stepsGoal = 10000;
  int caloriesBurned = 485;
  int caloriesGoal = 750;
  int workoutsThisWeek = 3;
  int activeMinutes = 142;
  double waterIntake = 1.8;

  // -------------------------
  // Today's exercises
  // -------------------------
  List<Exercise> todayExercises = [
    Exercise(
      name: 'Bench Press',
      category: 'Chest',
      bodyPart: 'Chest',
      equipment: 'Barbell',
      sets: [
        ExerciseSet(setNumber: 1, reps: 10, weight: 80.0),
        ExerciseSet(setNumber: 2, reps: 8, weight: 85.0),
        ExerciseSet(setNumber: 3, reps: 6, weight: 90.0),
      ],
    ),
    Exercise(
      name: 'Pull-Up',
      category: 'Back',
      bodyPart: 'Back',
      equipment: 'Bodyweight',
      sets: [
        ExerciseSet(setNumber: 1, reps: 12, weight: 0.0),
        ExerciseSet(setNumber: 2, reps: 10, weight: 0.0),
        ExerciseSet(setNumber: 3, reps: 8, weight: 0.0),
      ],
    ),
  ];

  bool _validExercise(int index) =>
      index >= 0 && index < todayExercises.length;

  void toggleExercise(int index) {
    if (!_validExercise(index)) return;
    todayExercises[index].isExpanded = !todayExercises[index].isExpanded;
    notifyListeners();
  }

  void toggleSet(int exerciseIndex, int setIndex) {
    if (!_validExercise(exerciseIndex)) return;
    final sets = todayExercises[exerciseIndex].sets;
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets[setIndex] = sets[setIndex].copyWith(
      isCompleted: !sets[setIndex].isCompleted,
    );
    notifyListeners();
  }

  void addExercise(
    String name, {
    String category = 'General',
    String bodyPart = 'Full Body',
    String equipment = 'None',
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    todayExercises.add(
      Exercise(
        name: trimmed,
        category: category,
        bodyPart: bodyPart,
        equipment: equipment,
        sets: [],
      ),
    );
    notifyListeners();
  }

  void deleteExercise(int index) {
    if (!_validExercise(index)) return;
    todayExercises.removeAt(index);
    notifyListeners();
  }

  void addSet(int exerciseIndex, int reps, double weight) {
    if (!_validExercise(exerciseIndex)) return;
    if (reps <= 0 || weight < 0) return;
    final exercise = todayExercises[exerciseIndex];
    exercise.sets.add(
      ExerciseSet(
        setNumber: exercise.sets.length + 1,
        reps: reps,
        weight: weight,
      ),
    );
    notifyListeners();
  }

  /// Removes a set and renumbers the remaining ones so [ExerciseSet.setNumber]
  /// always stays 1..n with no gaps.
  void deleteSet(int exerciseIndex, int setIndex) {
    if (!_validExercise(exerciseIndex)) return;
    final sets = todayExercises[exerciseIndex].sets;
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets.removeAt(setIndex);
    _renumber(sets);
    notifyListeners();
  }

  void updateExerciseSets(Exercise exercise, List<ExerciseSet> newSets) {
    final index = todayExercises.indexOf(exercise);
    if (index != -1) {
      final copy = List<ExerciseSet>.from(newSets);
      _renumber(copy);
      todayExercises[index].sets = copy;
      notifyListeners();
    }
  }

  void _renumber(List<ExerciseSet> sets) {
    for (var i = 0; i < sets.length; i++) {
      sets[i] = sets[i].copyWith(setNumber: i + 1);
    }
  }

  /// Jumps to the Workout tab so the START WORKOUT button actually does
  /// something instead of silently no-oping.
  void startWorkout() {
    setIndex(1);
  }

  // -------------------------
  // Meals
  // -------------------------
  List<Meal> meals = [
    Meal(
      name: 'Oatmeal with Berries',
      category: 'Breakfast',
      calories: 320,
      protein: 12.0,
      carbs: 58.0,
      fat: 6.0,
    ),
  ];

  int get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);
  double get totalProtein => meals.fold(0.0, (sum, m) => sum + m.protein);
  double get totalCarbs => meals.fold(0.0, (sum, m) => sum + m.carbs);
  double get totalFat => meals.fold(0.0, (sum, m) => sum + m.fat);

  List<Meal> get breakfastMeals =>
      meals.where((m) => m.category == 'Breakfast').toList();
  List<Meal> get lunchMeals =>
      meals.where((m) => m.category == 'Lunch').toList();
  List<Meal> get dinnerMeals =>
      meals.where((m) => m.category == 'Dinner').toList();
  List<Meal> get snackMeals =>
      meals.where((m) => m.category == 'Snack').toList();

  void addMeal(Meal meal) {
    if (meal.name.trim().isEmpty) return;
    meals.add(meal);
    notifyListeners();
  }

  void editMeal(Meal oldMeal, Meal newMeal) {
    int index = meals.indexOf(oldMeal);
    if (index != -1) {
      meals[index] = newMeal;
      notifyListeners();
    }
  }

  void deleteMeal(Meal meal) {
    meals.remove(meal);
    notifyListeners();
  }

  // -------------------------
  // Weight & workouts
  // -------------------------
  List<double> weightData = [
    82.5, 82.1, 81.8, 81.6, 81.2, 80.9, 80.7, 80.4, 80.1, 79.9, 79.7, 79.5,
  ];

  // -------------------------
  // Goals
  // -------------------------
  late List<Goal> goals;

  // -------------------------
  // Body measurements
  // -------------------------
  Map<String, double> bodyMeasurements = {
    'Chest': 102.5,
    'Waist': 82.0,
    'Hips': 98.5,
    'Thighs': 58.0,
    'Upper Arms': 36.5,
  };

  FitnessProvider() {
    goals = [
      Goal(
        title: 'WEIGHT LOSS',
        subtitle: 'Reach target body weight',
        current: 79.5,
        target: 75.0,
        unit: 'kg',
        icon: Icons.monitor_weight_outlined,
      ),
      Goal(
        title: 'DAILY STEPS',
        subtitle: 'Walk 10,000 steps every day',
        current: 7843,
        target: 10000,
        unit: 'steps',
        icon: Icons.directions_walk_outlined,
      ),
      Goal(
        title: 'CALORIES BURNED',
        subtitle: 'Burn 750 calories per day',
        current: 485,
        target: 750,
        unit: 'kcal',
        icon: Icons.local_fire_department_outlined,
      ),
      Goal(
        title: 'WORKOUT DAYS',
        subtitle: '4 workout sessions per week',
        current: 3,
        target: 4,
        unit: 'days',
        icon: Icons.fitness_center_outlined,
      ),
      Goal(
        title: 'WATER INTAKE',
        subtitle: 'Drink 2.5L of water daily',
        current: 1.8,
        target: 2.5,
        unit: 'L',
        icon: Icons.water_drop_outlined,
      ),
    ];
  }

  void addGoal(String title, double current, double target, String unit) {
    final trimmed = title.trim();
    if (trimmed.isEmpty || target <= 0 || current < 0) return;
    goals.add(Goal(
      title: trimmed,
      subtitle: 'Custom goal',
      current: current,
      target: target,
      unit: unit.trim(),
      icon: Icons.flag_outlined,
    ));
    notifyListeners();
  }

  void updateGoal(int index, double current, double target) {
    if (index < 0 || index >= goals.length) return;
    if (target <= 0 || current < 0) return;
    final goal = goals[index];
    goals[index] = Goal(
      title: goal.title,
      subtitle: goal.subtitle,
      current: current,
      target: target,
      unit: goal.unit,
      icon: goal.icon,
    );
    notifyListeners();
  }

  void deleteGoal(int index) {
    if (index >= 0 && index < goals.length) {
      goals.removeAt(index);
      notifyListeners();
    }
  }

  void addMeasurement(String name, double value) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || value <= 0) return;
    bodyMeasurements[trimmed] = value;
    notifyListeners();
  }

  void editMeasurement(String oldName, String newName, double newValue) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || newValue <= 0) return;
    if (oldName != trimmed) {
      bodyMeasurements.remove(oldName);
    }
    bodyMeasurements[trimmed] = newValue;
    notifyListeners();
  }

  void deleteMeasurement(String name) {
    bodyMeasurements.remove(name);
    notifyListeners();
  }

  void addWeight(double weight) {
    if (weight <= 0) return;
    weightData.add(weight);
    notifyListeners();
  }

  void editWeight(int index, double weight) {
    if (index >= 0 && index < weightData.length && weight > 0) {
      weightData[index] = weight;
      notifyListeners();
    }
  }

  void deleteWeight(int index) {
    if (index >= 0 && index < weightData.length) {
      weightData.removeAt(index);
      notifyListeners();
    }
  }

  void setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  double get overallGoalProgress {
    if (goals.isEmpty) return 0.0;
    return goals.fold(0.0, (sum, g) => sum + g.progress) / goals.length;
  }
}