import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const WorkoutDetailScreen({super.key, required this.exercise});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late List<ExerciseSet> _sets;

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.exercise.sets);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return const Color(0xFFFF6B35);
      case 'back':
        return const Color(0xFF4ECDC4);
      case 'shoulders':
        return const Color(0xFF9B59B6);
      case 'hips':
        return const Color(0xFFE74C3C);
      case 'aerobic':
        return const Color(0xFF2ECC71);
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final categoryColor = _getCategoryColor(exercise.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'EXERCISE DETAIL',
          style: GoogleFonts.barlowCondensed(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero + Exercise Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: Row(
                children: [
                  // SVG-style placeholder silhouette
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Head
                        Positioned(
                          top: 10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF555555),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Body
                        Positioned(
                          top: 30,
                          child: Container(
                            width: 28,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFF555555),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        // Legs
                        Positioned(
                          bottom: 8,
                          left: 20,
                          child: Container(
                            width: 10,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF555555),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 20,
                          child: Container(
                            width: 10,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF555555),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: exercise.name,
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              exercise.name.toUpperCase(),
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildChip(exercise.category, categoryColor),
                            _buildChip(exercise.bodyPart, AppColors.textMuted),
                            _buildChip(exercise.equipment, AppColors.textMuted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sets Table
            Text(
              'SETS',
              style: GoogleFonts.barlowCondensed(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            'SET',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'REPS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'WEIGHT',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            'LOG',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table rows
                  ...List.generate(_sets.length, (index) {
                    final set = _sets[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: set.isCompleted
                            ? AppColors.accent.withValues(alpha: 0.05)
                            : Colors.transparent,
                        border: index < _sets.length - 1
                            ? const Border(
                                bottom: BorderSide(
                                    color: AppColors.divider, width: 1),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${set.setNumber}',
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: set.isCompleted
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${set.reps}',
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              set.weight > 0
                                  ? '${set.weight} kg'
                                  : 'BW',
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _sets[index] = ExerciseSet(
                                      setNumber: set.setNumber,
                                      reps: set.reps,
                                      weight: set.weight,
                                      isCompleted: !set.isCompleted,
                                    );
                                  });
                                  context.read<FitnessProvider>().updateExerciseSets(widget.exercise, _sets);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: set.isCompleted
                                        ? AppColors.accent
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: set.isCompleted
                                          ? AppColors.accent
                                          : AppColors.divider,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    set.isCompleted ? 'DONE' : 'LOG',
                                    style: GoogleFonts.barlow(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: set.isCompleted
                                          ? Colors.black
                                          : AppColors.textMuted,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary stats
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'TOTAL SETS',
                    '${_sets.length}',
                    Icons.layers_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'COMPLETED',
                    '${_sets.where((s) => s.isCompleted).length}',
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'TOTAL REPS',
                    '${_sets.fold(0, (sum, s) => sum + s.reps)}',
                    Icons.repeat,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Add Set Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
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
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accent, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '+ ADD SET',
                  style: GoogleFonts.barlow(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color == AppColors.textMuted ? AppColors.textMuted : color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.barlowCondensed(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
