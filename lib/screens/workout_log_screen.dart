import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';

class WorkoutLogScreen extends StatelessWidget {
  const WorkoutLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Log'),
        backgroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // --- Existing daily stats ---
          Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  _statWidget("Steps", provider.steps.toDouble(), provider.stepsGoal.toDouble()),
                  _statWidget(
                      "Calories", provider.caloriesBurned.toDouble(), provider.caloriesGoal.toDouble()),
                  _statWidget(
                      "Workouts", provider.workoutsThisWeek.toDouble(), 7.0), // weekly goal
                  _statWidget("Water", provider.waterIntake, 2.5, isDouble: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // --- Exercises list ---
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.todayExercises.length,
            itemBuilder: (context, index) {
              final exercise = provider.todayExercises[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  key: Key('${exercise.name}_$index'),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  initiallyExpanded: exercise.isExpanded,
                  onExpansionChanged: (_) => provider.toggleExercise(index),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                      "${exercise.category} • ${exercise.bodyPart} • ${exercise.equipment}"),
                  children: [
                    ...exercise.sets.map(
                          (set) {
                        int setIndex = exercise.sets.indexOf(set);
                        return ListTile(
                          leading: Checkbox(
                            value: set.isCompleted,
                            onChanged: (_) =>
                                provider.toggleSet(index, setIndex),
                          ),
                          title: Text("Set ${set.setNumber}"),
                          subtitle:
                          Text("${set.reps} reps • ${set.weight} kg"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              Future.delayed(Duration.zero, () {
                                exercise.sets.removeAt(setIndex);
                                provider.updateExerciseSets(exercise, exercise.sets);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showAddSetDialog(context, provider, index),
                        icon: const Icon(Icons.add),
                        label: const Text("Add Set"),
                      ),
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

  Widget _statWidget(String title, double current, double goal,
      {bool isDouble = false}) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            isDouble ? "${current.toStringAsFixed(1)} / $goal" : "${current.toInt()} / ${goal.toInt()}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: LinearProgressIndicator(value: progress, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final text = controller.text.trim();
                Navigator.pop(dialogContext, text);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      provider.addExercise(result);
    }
  }

  void _showAddSetDialog(
      BuildContext context, FitnessProvider provider, int exerciseIndex) async {
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Set"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Reps"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Weight (kg)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text.trim()) ?? 0;
              final weight =
                  double.tryParse(weightController.text.trim()) ?? 0.0;
              if (reps > 0) {
                Navigator.pop(dialogContext, {'reps': reps, 'weight': weight});
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      provider.addSet(exerciseIndex, result['reps'] as int, result['weight'] as double);
    }
  }
}