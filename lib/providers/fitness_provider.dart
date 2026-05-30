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

  void toggleExercise(int index) {
    todayExercises[index].isExpanded = !todayExercises[index].isExpanded;
    notifyListeners();
  }

  void toggleSet(int exerciseIndex, int setIndex) {
    var set = todayExercises[exerciseIndex].sets[setIndex];
    todayExercises[exerciseIndex].sets[setIndex] =
        set.copyWith(isCompleted: !set.isCompleted);
    notifyListeners();
  }

  void addExercise(String name) {
    todayExercises.add(
      Exercise(
        name: name,
        category: "General",
        bodyPart: "Full Body",
        equipment: "None",
        sets: [],
      ),
    );
    notifyListeners();
  }

  void addSet(int exerciseIndex, int reps, double weight) {
    var exercise = todayExercises[exerciseIndex];
    int setNumber = exercise.sets.length + 1;
    exercise.sets.add(
      ExerciseSet(setNumber: setNumber, reps: reps, weight: weight),
    );
    notifyListeners();
  }

  void updateExerciseSets(Exercise exercise, List<ExerciseSet> newSets) {
    int index = todayExercises.indexOf(exercise);
    if (index != -1) {
      todayExercises[index].sets = List.from(newSets);
      notifyListeners();
    }
  }

  void startWorkout() {
    // Workout started
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

  List<double> weeklyWorkouts = [3, 4, 3, 5, 4, 3, 4];

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
    goals.add(Goal(
      title: title,
      subtitle: 'Custom goal',
      current: current,
      target: target,
      unit: unit,
      icon: Icons.flag_outlined,
    ));
    notifyListeners();
  }

  void updateGoal(int index, double current, double target) {
    if (index >= 0 && index < goals.length) {
      var goal = goals[index];
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
  }

  void deleteGoal(int index) {
    if (index >= 0 && index < goals.length) {
      goals.removeAt(index);
      notifyListeners();
    }
  }

  void addMeasurement(String name, double value) {
    bodyMeasurements[name] = value;
    notifyListeners();
  }

  void editMeasurement(String oldName, String newName, double newValue) {
    if (oldName != newName) {
      bodyMeasurements.remove(oldName);
    }
    bodyMeasurements[newName] = newValue;
    notifyListeners();
  }

  void deleteMeasurement(String name) {
    bodyMeasurements.remove(name);
    notifyListeners();
  }

  void addWeight(double weight) {
    weightData.add(weight);
    notifyListeners();
  }

  void editWeight(int index, double weight) {
    if (index >= 0 && index < weightData.length) {
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