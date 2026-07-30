// Unit tests for FitnessProvider — the single source of truth for all app
// state. These are pure Dart tests (no widgets), so they run fast and can't
// be affected by fonts, animations or layout.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/models/models.dart';
import 'package:fitness_tracker/providers/fitness_provider.dart';

void main() {
  late FitnessProvider provider;

  setUp(() => provider = FitnessProvider());

  group('models', () {
    test('an Exercise built without sets still accepts new sets', () {
      // Regression: the old `sets = const []` default produced an
      // unmodifiable list and threw on the first add.
      final exercise = Exercise(
        name: 'Squat',
        category: 'Legs',
        bodyPart: 'Legs',
        equipment: 'Barbell',
      );

      expect(
        () => exercise.sets.add(
          ExerciseSet(setNumber: 1, reps: 5, weight: 100),
        ),
        returnsNormally,
      );
      expect(exercise.totalSets, 1);
    });

    test('the caller\'s list is copied, not aliased', () {
      final original = [ExerciseSet(setNumber: 1, reps: 5, weight: 60)];
      final exercise = Exercise(
        name: 'Row',
        category: 'Back',
        bodyPart: 'Back',
        equipment: 'Barbell',
        sets: original,
      );

      exercise.sets.add(ExerciseSet(setNumber: 2, reps: 5, weight: 60));

      expect(original.length, 1, reason: 'caller list must not be mutated');
      expect(exercise.totalSets, 2);
    });

    test('ExerciseSet.copyWith updates only what it is given', () {
      final set = ExerciseSet(setNumber: 1, reps: 10, weight: 80);
      final updated = set.copyWith(isCompleted: true);

      expect(updated.setNumber, 1);
      expect(updated.reps, 10);
      expect(updated.weight, 80);
      expect(updated.isCompleted, isTrue);
      expect(set.isCompleted, isFalse, reason: 'original stays untouched');
    });

    test('weight labels drop trailing zeros and handle bodyweight', () {
      expect(ExerciseSet(setNumber: 1, reps: 8, weight: 80).weightLabel,
          '80 kg');
      expect(ExerciseSet(setNumber: 1, reps: 8, weight: 82.5).weightLabel,
          '82.5 kg');
      expect(ExerciseSet(setNumber: 1, reps: 8, weight: 0).weightLabel, 'BW');
    });

    test('Goal.progress is clamped to 0..1', () {
      final over = Goal(
        title: 'X',
        subtitle: '',
        current: 200,
        target: 100,
        unit: 'kg',
        icon: Icons.flag_outlined,
      );
      expect(over.progress, 1.0);
    });
  });

  group('meals', () {
    test('totals reflect the seeded meal', () {
      expect(provider.meals.length, 1);
      expect(provider.totalCalories, 320);
      expect(provider.totalProtein, 12.0);
      expect(provider.totalCarbs, 58.0);
      expect(provider.totalFat, 6.0);
    });

    test('addMeal updates totals and notifies', () {
      var notified = 0;
      provider.addListener(() => notified++);

      provider.addMeal(Meal(
        name: 'Chicken Rice',
        category: 'Lunch',
        calories: 600,
        protein: 45,
        carbs: 70,
        fat: 12,
      ));

      expect(provider.meals.length, 2);
      expect(provider.totalCalories, 920);
      expect(provider.totalProtein, 57.0);
      expect(notified, 1);
    });

    test('addMeal rejects a blank name', () {
      provider.addMeal(Meal(
        name: '   ',
        category: 'Lunch',
        calories: 100,
        protein: 1,
        carbs: 1,
        fat: 1,
      ));

      expect(provider.meals.length, 1);
    });

    test('category getters split meals correctly', () {
      provider.addMeal(Meal(
        name: 'Steak',
        category: 'Dinner',
        calories: 700,
        protein: 50,
        carbs: 5,
        fat: 40,
      ));

      expect(provider.breakfastMeals.length, 1);
      expect(provider.dinnerMeals.length, 1);
      expect(provider.lunchMeals, isEmpty);
      expect(provider.snackMeals, isEmpty);
    });

    test('editMeal swaps the meal in place', () {
      final original = provider.meals.first;
      final replacement = Meal(
        name: 'Porridge',
        category: 'Breakfast',
        calories: 250,
        protein: 10,
        carbs: 40,
        fat: 4,
      );

      provider.editMeal(original, replacement);

      expect(provider.meals.length, 1);
      expect(provider.meals.first.name, 'Porridge');
      expect(provider.totalCalories, 250);
    });

    test('deleteMeal removes it', () {
      provider.deleteMeal(provider.meals.first);

      expect(provider.meals, isEmpty);
      expect(provider.totalCalories, 0);
    });
  });

  group('exercises and sets', () {
    test('seed data is present', () {
      expect(provider.todayExercises.length, 2);
      expect(provider.todayExercises.first.name, 'Bench Press');
      expect(provider.todayExercises.first.totalSets, 3);
    });

    test('addExercise appends with defaults and trims the name', () {
      provider.addExercise('  Deadlift  ');

      final added = provider.todayExercises.last;
      expect(provider.todayExercises.length, 3);
      expect(added.name, 'Deadlift');
      expect(added.category, 'General');
      expect(added.totalSets, 0);
    });

    test('addExercise honours a custom category', () {
      provider.addExercise('Curl', category: 'Arms');
      expect(provider.todayExercises.last.category, 'Arms');
    });

    test('addExercise ignores blank names', () {
      provider.addExercise('   ');
      expect(provider.todayExercises.length, 2);
    });

    test('a freshly added exercise accepts sets', () {
      provider.addExercise('Plank');
      final index = provider.todayExercises.length - 1;

      provider.addSet(index, 30, 0);

      expect(provider.todayExercises[index].totalSets, 1);
      expect(provider.todayExercises[index].sets.first.setNumber, 1);
    });

    test('addSet numbers sets sequentially', () {
      provider.addSet(0, 12, 60);

      final sets = provider.todayExercises[0].sets;
      expect(sets.length, 4);
      expect(sets.last.setNumber, 4);
      expect(sets.last.reps, 12);
      expect(sets.last.weight, 60);
    });

    test('addSet rejects non-positive reps and negative weight', () {
      provider.addSet(0, 0, 50);
      provider.addSet(0, -3, 50);
      provider.addSet(0, 10, -1);

      expect(provider.todayExercises[0].totalSets, 3);
    });

    test('deleteSet removes the set and renumbers the rest', () {
      provider.deleteSet(0, 0); // drop set 1 of 3

      final sets = provider.todayExercises[0].sets;
      expect(sets.length, 2);
      expect(sets.map((s) => s.setNumber), [1, 2]);
      // The surviving sets kept their own data.
      expect(sets[0].reps, 8);
      expect(sets[1].reps, 6);
    });

    test('toggleSet flips completion and updates the counter', () {
      expect(provider.todayExercises[0].completedSets, 0);

      provider.toggleSet(0, 1);
      expect(provider.todayExercises[0].sets[1].isCompleted, isTrue);
      expect(provider.todayExercises[0].completedSets, 1);

      provider.toggleSet(0, 1);
      expect(provider.todayExercises[0].completedSets, 0);
    });

    test('toggleExercise flips the expansion flag', () {
      expect(provider.todayExercises[0].isExpanded, isFalse);
      provider.toggleExercise(0);
      expect(provider.todayExercises[0].isExpanded, isTrue);
    });

    test('deleteExercise removes it', () {
      provider.deleteExercise(0);
      expect(provider.todayExercises.length, 1);
      expect(provider.todayExercises.first.name, 'Pull-Up');
    });

    test('updateExerciseSets replaces and renumbers', () {
      final exercise = provider.todayExercises[0];

      provider.updateExerciseSets(exercise, [
        ExerciseSet(setNumber: 99, reps: 5, weight: 100),
        ExerciseSet(setNumber: 42, reps: 5, weight: 100),
      ]);

      expect(exercise.sets.length, 2);
      expect(exercise.sets.map((s) => s.setNumber), [1, 2]);
    });

    test('totalReps sums every set', () {
      // Bench Press seed: 10 + 8 + 6
      expect(provider.todayExercises[0].totalReps, 24);
    });

    test('out-of-range indices are ignored rather than throwing', () {
      expect(() => provider.toggleExercise(99), returnsNormally);
      expect(() => provider.toggleSet(99, 0), returnsNormally);
      expect(() => provider.toggleSet(0, 99), returnsNormally);
      expect(() => provider.addSet(99, 5, 5), returnsNormally);
      expect(() => provider.deleteSet(0, 99), returnsNormally);
      expect(() => provider.deleteExercise(-1), returnsNormally);
      expect(provider.todayExercises.length, 2);
    });
  });

  group('goals', () {
    test('five goals are seeded', () {
      expect(provider.goals.length, 5);
    });

    test('overallGoalProgress averages every goal', () {
      final expected =
          provider.goals.fold<double>(0, (sum, g) => sum + g.progress) /
              provider.goals.length;

      expect(provider.overallGoalProgress, closeTo(expected, 1e-9));
      expect(provider.overallGoalProgress, inInclusiveRange(0.0, 1.0));
    });

    test('addGoal appends a custom goal', () {
      provider.addGoal('Sleep', 6, 8, 'hrs');

      final added = provider.goals.last;
      expect(provider.goals.length, 6);
      expect(added.title, 'Sleep');
      expect(added.target, 8);
      expect(added.progress, closeTo(0.75, 1e-9));
    });

    test('addGoal rejects a blank title or a non-positive target', () {
      provider.addGoal('', 1, 10, 'kg');
      provider.addGoal('Valid', 1, 0, 'kg');
      provider.addGoal('Valid', 1, -5, 'kg');

      expect(provider.goals.length, 5);
    });

    test('updateGoal changes values but keeps identity fields', () {
      final before = provider.goals[0];

      provider.updateGoal(0, 78, 74);

      final after = provider.goals[0];
      expect(after.title, before.title);
      expect(after.unit, before.unit);
      expect(after.current, 78);
      expect(after.target, 74);
    });

    test('updateGoal ignores an invalid target', () {
      provider.updateGoal(0, 78, 0);
      expect(provider.goals[0].target, 75.0);
    });

    test('deleteGoal removes by index and ignores bad indices', () {
      provider.deleteGoal(0);
      expect(provider.goals.length, 4);

      provider.deleteGoal(99);
      expect(provider.goals.length, 4);
    });

    test('overallGoalProgress is 0 when there are no goals', () {
      while (provider.goals.isNotEmpty) {
        provider.deleteGoal(0);
      }
      expect(provider.overallGoalProgress, 0.0);
    });
  });

  group('weight', () {
    test('seed data has twelve entries', () {
      expect(provider.weightData.length, 12);
      expect(provider.weightData.last, 79.5);
    });

    test('addWeight appends and rejects non-positive values', () {
      provider.addWeight(79.0);
      expect(provider.weightData.length, 13);

      provider.addWeight(0);
      provider.addWeight(-5);
      expect(provider.weightData.length, 13);
    });

    test('editWeight updates in place, guarded by index and value', () {
      provider.editWeight(0, 83.0);
      expect(provider.weightData[0], 83.0);

      provider.editWeight(99, 50);
      provider.editWeight(0, 0);
      expect(provider.weightData[0], 83.0);
    });

    test('deleteWeight removes by index', () {
      provider.deleteWeight(0);
      expect(provider.weightData.length, 11);
      expect(provider.weightData.first, 82.1);

      provider.deleteWeight(99);
      expect(provider.weightData.length, 11);
    });
  });

  group('body measurements', () {
    test('five measurements are seeded', () {
      expect(provider.bodyMeasurements.length, 5);
      expect(provider.bodyMeasurements['Chest'], 102.5);
    });

    test('addMeasurement trims and validates', () {
      provider.addMeasurement('  Calves  ', 40);
      expect(provider.bodyMeasurements['Calves'], 40);

      provider.addMeasurement('', 40);
      provider.addMeasurement('Bad', 0);
      expect(provider.bodyMeasurements.length, 6);
    });

    test('editMeasurement renames without leaving the old key behind', () {
      provider.editMeasurement('Chest', 'Upper Chest', 104);

      expect(provider.bodyMeasurements.containsKey('Chest'), isFalse);
      expect(provider.bodyMeasurements['Upper Chest'], 104);
      expect(provider.bodyMeasurements.length, 5);
    });

    test('editMeasurement can change only the value', () {
      provider.editMeasurement('Waist', 'Waist', 80);

      expect(provider.bodyMeasurements['Waist'], 80);
      expect(provider.bodyMeasurements.length, 5);
    });

    test('deleteMeasurement removes the key', () {
      provider.deleteMeasurement('Hips');
      expect(provider.bodyMeasurements.containsKey('Hips'), isFalse);
    });
  });

  group('navigation', () {
    test('setIndex updates the selected tab and notifies', () {
      var notified = 0;
      provider.addListener(() => notified++);

      provider.setIndex(3);

      expect(provider.selectedIndex, 3);
      expect(notified, 1);
    });

    test('startWorkout jumps to the workout tab', () {
      expect(provider.selectedIndex, 0);
      provider.startWorkout();
      expect(provider.selectedIndex, 1);
    });
  });
}
