import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/stat_card.dart';
import '../widgets/volume_scroll_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING,';
    if (hour < 17) return 'GOOD AFTERNOON,';
    return 'GOOD EVENING,';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FitnessProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'FIT',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 3,
                ),
              ),
              TextSpan(
                text: 'TRACK',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: AppColors.textPrimary,
              ),
              if (provider.hasNotifications)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: VolumeScrollList(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                provider.userName.toUpperCase(),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                  height: 1.0,
                ),
              ),
              Text(
                _formattedDate(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Circular Progress Rings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularProgressWidget(
                  progress: provider.steps / provider.stepsGoal,
                  size: 130,
                  strokeWidth: 10,
                  color: AppColors.accent,
                  label: 'STEPS',
                  value: provider.steps.toString(),
                  unit: '/ ${provider.stepsGoal}',
                ),
                Container(
                  width: 1,
                  height: 100,
                  color: AppColors.divider,
                ),
                CircularProgressWidget(
                  progress: provider.caloriesBurned / provider.caloriesGoal,
                  size: 130,
                  strokeWidth: 10,
                  color: AppColors.accentRed,
                  label: 'CALORIES',
                  value: provider.caloriesBurned.toString(),
                  unit: '/ ${provider.caloriesGoal} kcal',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stat Cards Row with mini progress
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'WORKOUTS',
                  value: provider.workoutsThisWeek.toString(),
                  unit: 'this week',
                  icon: Icons.fitness_center_outlined,
                  progress: provider.workoutsThisWeek / provider.workoutsGoal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'ACTIVE MIN',
                  value: provider.activeMinutes.toString(),
                  unit: 'min',
                  icon: Icons.timer_outlined,
                  progress: provider.activeMinutes / provider.activeMinutesGoal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'WATER',
                  value: provider.waterIntake.toString(),
                  unit: 'L',
                  icon: Icons.water_drop_outlined,
                  progress: provider.waterIntake / provider.waterGoal,
                  accentLeft: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Upcoming Workout Card
          // Flutter forbids borderRadius + non-uniform border widths, so we
          // use an outer uniform-border container + inner ClipRRect accent strip.
          Container(
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
                    Container(width: 4, color: AppColors.accent),
                    Expanded(
                      child: Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.all(16),
                        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TODAY\'S WORKOUT',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${provider.todayWorkoutDuration} MIN',
                        style: GoogleFonts.barlow(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  provider.todayWorkoutName,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                    height: 1.0,
                  ),
                ),
                Text(
                  provider.todayWorkoutFocus,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 12),
                ...provider.todayExercises.take(6).map((exercise) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          exercise.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${exercise.totalSets} sets',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: provider.todayExercises.isNotEmpty
                        ? () => provider.startWorkout()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'START WORKOUT',
                      style: GoogleFonts.barlow(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Weekly Summary
          Container(
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
                  'WEEKLY SUMMARY',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: provider.weeklyStatus.map((day) {
                    return _buildWeekDay(day['day'], day['completed']);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDay(String day, bool completed) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: completed
                ? AppColors.accent
                : AppColors.divider.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.remove,
            size: 16,
            color: completed ? Colors.black : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}