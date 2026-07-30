import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/models.dart';
import '../providers/fitness_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/volume_scroll_list.dart';
import 'workout_detail_screen.dart';

class WorkoutLogScreen extends StatelessWidget {
  const WorkoutLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitnessProvider>();
    final exercises = provider.todayExercises;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'WORKOUT LOG',
          style: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addExercise(context, provider),
        backgroundColor: AppColors.accent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
      body: VolumeScrollList(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        children: [
          // ── Daily stats summary ────────────────────────────────────────
          _DailyStatsCard(provider: provider),

          const SizedBox(height: 20),

          // ── Section header ─────────────────────────────────────────────
          Row(
            children: [
              Text(
                'TODAY\'S EXERCISES',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${exercises.length}',
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Exercise list (or empty state) ─────────────────────────────
          if (exercises.isEmpty)
            const _EmptyExercises()
          else
            ...List.generate(
              exercises.length,
              (index) => _ExerciseCard(
                exercise: exercises[index],
                index: index,
                provider: provider,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily stats
// ─────────────────────────────────────────────────────────────────────────────

class _DailyStatsCard extends StatelessWidget {
  final FitnessProvider provider;

  const _DailyStatsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY\'S ACTIVITY',
            style: GoogleFonts.barlowCondensed(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniStat(
                title: 'STEPS',
                value: provider.steps.toString(),
                goal: provider.stepsGoal.toString(),
                progress: provider.steps / provider.stepsGoal,
              ),
              _MiniStat(
                title: 'CALORIES',
                value: provider.caloriesBurned.toString(),
                goal: provider.caloriesGoal.toString(),
                progress: provider.caloriesBurned / provider.caloriesGoal,
              ),
              _MiniStat(
                title: 'WORKOUTS',
                value: provider.workoutsThisWeek.toString(),
                goal: provider.workoutsGoal.toString(),
                progress: provider.workoutsThisWeek / provider.workoutsGoal,
              ),
              _MiniStat(
                title: 'WATER',
                value: provider.waterIntake.toStringAsFixed(1),
                goal: provider.waterGoal.toStringAsFixed(1),
                progress: provider.waterIntake / provider.waterGoal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final String goal;
  final double progress;

  const _MiniStat({
    required this.title,
    required this.value,
    required this.goal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  TextSpan(
                    text: ' / $goal',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exercise card
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final FitnessProvider provider;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // Unique per row so two exercises sharing a name can't trip the
    // "multiple heroes share the same tag" assertion.
    final heroTag = 'exercise_${index}_${exercise.name}';
    final done = exercise.completedSets;
    final total = exercise.totalSets;
    final allDone = total > 0 && done == total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      // Material hosts the InkWell so the tap ripple is actually visible
      // on top of the card surface instead of behind it.
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Header (tap to expand/collapse) ────────────────────────
            InkWell(
              onTap: () => provider.toggleExercise(index),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: heroTag,
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                exercise.name.toUpperCase(),
                                style: GoogleFonts.barlowCondensed(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${exercise.category} • ${exercise.bodyPart} • ${exercise.equipment}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sets progress badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: allDone
                            ? AppColors.accent.withValues(alpha: 0.16)
                            : AppColors.divider.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$done/$total',
                        style: GoogleFonts.barlow(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: allDone
                              ? AppColors.accent
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    // Open the full detail / logging screen
                    IconButton(
                      tooltip: 'Open details',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.open_in_new,
                          size: 18, color: AppColors.accent),
                      onPressed: () => Navigator.push(
                        context,
                        MainNavigator.slideRoute(
                          WorkoutDetailScreen(
                            exercise: exercise,
                            heroTag: heroTag,
                          ),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: exercise.isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable set list ────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: _SetList(
                exercise: exercise,
                index: index,
                provider: provider,
              ),
              crossFadeState: exercise.isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetList extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final FitnessProvider provider;

  const _SetList({
    required this.exercise,
    required this.index,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.divider, height: 1),
        if (exercise.sets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No sets logged yet',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          )
        else
          ...List.generate(exercise.sets.length, (setIndex) {
            final set = exercise.sets[setIndex];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: set.isCompleted
                  ? AppColors.accent.withValues(alpha: 0.04)
                  : Colors.transparent,
              child: Row(
                children: [
                  Checkbox(
                    value: set.isCompleted,
                    onChanged: (_) => provider.toggleSet(index, setIndex),
                    activeColor: AppColors.accent,
                    checkColor: Colors.black,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(
                        color: AppColors.textMuted, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SET ${set.setNumber}',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: set.isCompleted
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      '${set.reps} reps • ${set.weightLabel}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete set',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.textMuted),
                    onPressed: () => provider.deleteSet(index, setIndex),
                  ),
                ],
              ),
            );
          }),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addSet(context, provider, index),
                  icon: const Icon(Icons.add,
                      size: 16, color: AppColors.accent),
                  label: Text(
                    'ADD SET',
                    style: GoogleFonts.barlow(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    side: const BorderSide(color: AppColors.accent, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _deleteExercise(context, provider, index),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  side: const BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center_outlined,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'NO EXERCISES YET',
            style: GoogleFonts.barlowCondensed(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first exercise',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog launchers
//
// Each dialog body is its own StatefulWidget so it can own — and correctly
// dispose — its TextEditingControllers. Disposing them right after
// `await showDialog` would risk "used after being disposed" while the
// dismissal animation is still rendering the fields.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _addExercise(
    BuildContext context, FitnessProvider provider) async {
  final result = await showDialog<_NewExercise>(
    context: context,
    builder: (_) => const _AddExerciseDialog(),
  );
  if (result == null) return;

  provider.addExercise(result.name, category: result.category);
  if (context.mounted) {
    _toast(context, '${result.name} added');
  }
}

Future<void> _addSet(
    BuildContext context, FitnessProvider provider, int exerciseIndex) async {
  final result = await showDialog<_NewSet>(
    context: context,
    builder: (_) => const _AddSetDialog(),
  );
  if (result == null) return;

  provider.addSet(exerciseIndex, result.reps, result.weight);
}

Future<void> _deleteExercise(
    BuildContext context, FitnessProvider provider, int index) async {
  if (index < 0 || index >= provider.todayExercises.length) return;
  final name = provider.todayExercises[index].name;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'DELETE EXERCISE?',
        style: GoogleFonts.barlowCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
      ),
      content: Text(
        'Remove "$name" and all of its sets?',
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    provider.deleteExercise(index);
    if (context.mounted) {
      _toast(context, '$name deleted');
    }
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog bodies
// ─────────────────────────────────────────────────────────────────────────────

/// Result of the add-exercise dialog.
class _NewExercise {
  final String name;
  final String category;
  const _NewExercise(this.name, this.category);
}

/// Result of the add-set dialog.
class _NewSet {
  final int reps;
  final double weight;
  const _NewSet(this.reps, this.weight);
}

class _AddExerciseDialog extends StatefulWidget {
  const _AddExerciseDialog();

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter an exercise name');
      return;
    }
    final category = _categoryCtrl.text.trim();
    Navigator.pop(
      context,
      _NewExercise(name, category.isEmpty ? 'General' : category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'ADD EXERCISE',
        style: GoogleFonts.barlowCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Exercise Name',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _categoryCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Category (optional, e.g. Chest)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          child: const Text('ADD'),
        ),
      ],
    );
  }
}

class _AddSetDialog extends StatefulWidget {
  const _AddSetDialog();

  @override
  State<_AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<_AddSetDialog> {
  final _repsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _repsError;
  String? _weightError;

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final reps = int.tryParse(_repsCtrl.text.trim());
    final weightText = _weightCtrl.text.trim();
    // Empty weight is allowed and means bodyweight (0 kg).
    final weight = weightText.isEmpty ? 0.0 : double.tryParse(weightText);

    setState(() {
      _repsError =
          (reps == null || reps <= 0) ? 'Enter reps greater than 0' : null;
      _weightError = (weight == null || weight < 0)
          ? 'Enter a valid weight (0 or more)'
          : null;
    });

    if (reps == null || reps <= 0) return;
    if (weight == null || weight < 0) return;

    Navigator.pop(context, _NewSet(reps, weight));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'ADD SET',
        style: GoogleFonts.barlowCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _repsCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Reps',
              errorText: _repsError,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Weight (kg) — leave empty for bodyweight',
              errorText: _weightError,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          child: const Text('ADD'),
        ),
      ],
    );
  }
}
