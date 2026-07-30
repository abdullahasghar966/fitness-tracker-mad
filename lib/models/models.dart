import 'package:flutter/material.dart';

/// -------------------------
/// Exercise & Sets Models
/// -------------------------
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

  /// Whole numbers render as "80" rather than "80.0".
  String get formattedWeight =>
      weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1);

  /// Weight label including the bodyweight case.
  String get weightLabel => weight > 0 ? '$formattedWeight kg' : 'BW';

  ExerciseSet copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Exercise {
  final String name;
  final String category;
  final String bodyPart;
  final String equipment;
  List<ExerciseSet> sets;
  bool isExpanded;

  /// [sets] is copied into a growable list so callers can always add/remove
  /// sets. Passing a `const []` literal previously produced an unmodifiable
  /// list and threw "Cannot add to an unmodifiable list" on the first addSet.
  Exercise({
    required this.name,
    required this.category,
    required this.bodyPart,
    required this.equipment,
    List<ExerciseSet>? sets,
    this.isExpanded = false,
  }) : sets = List<ExerciseSet>.from(sets ?? const []);

  int get totalSets => sets.length;

  int get completedSets =>
      sets.where((set) => set.isCompleted).length;

  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);
}

/// -------------------------
/// Meal Model
/// -------------------------
class Meal {
  final String name;
  final String category; // Breakfast, Lunch, Dinner, Snack
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  Meal({
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

/// -------------------------
/// Goal Model
/// -------------------------
class Goal {
  final String title;
  final String subtitle;
  final double current;
  final double target;
  final String unit;
  final IconData icon;

  Goal({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.target,
    required this.unit,
    required this.icon,
  });

  /// Guarded against a zero/negative target: `0 / 0` is NaN, and NaN survives
  /// `clamp`, which would then trip an assertion inside the progress widgets.
  double get progress {
    if (target <= 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }
}