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

  ExerciseSet copyWith({bool? isCompleted}) {
    return ExerciseSet(
      setNumber: setNumber,
      reps: reps,
      weight: weight,
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

  Exercise({
    required this.name,
    required this.category,
    required this.bodyPart,
    required this.equipment,
    this.sets = const [],
    this.isExpanded = false,
  });

  int get totalSets => sets.length;

  int get completedSets =>
      sets.where((set) => set.isCompleted).length;
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

  double get progress => (current / target).clamp(0.0, 1.0);
}