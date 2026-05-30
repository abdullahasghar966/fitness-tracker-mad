import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/goal_card.dart';
import '../widgets/volume_scroll_list.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'MY GOALS',
          style: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          final overallPercent =
          (provider.overallGoalProgress * 100).toStringAsFixed(0);

          return Column(
            children: [
              // Overall progress header with circular indicator
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
                    left: BorderSide(color: AppColors.accent, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OVERALL PROGRESS',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You\'re $overallPercent% there. Keep going!',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Linear overall progress bar
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: provider.overallGoalProgress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$overallPercent%',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Goals count row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'ACTIVE GOALS',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${provider.goals.length}',
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Goals list
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: provider.goals.length,
                  itemBuilder: (context, index) {
                    final goal = provider.goals[index];
                    final progress = (goal.current / goal.target)
                        .clamp(0.0, 1.0);

                    return VolumeListItem(
                      scrollController: _scrollCtrl,
                      revealDelay: Duration(milliseconds: index * 80),
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

              // Add Goal Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _showAddGoalDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'ADD GOAL',
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADD NEW GOAL',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Value',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unit (kg, cm, etc.)',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final provider = context.read<FitnessProvider>();
                    final title = titleCtrl.text.trim();
                    final current = double.tryParse(currentCtrl.text.trim()) ?? 0;
                    final target = double.tryParse(targetCtrl.text.trim()) ?? 0;
                    final unit = unitCtrl.text.trim();

                    if (title.isNotEmpty && target > 0) {
                      provider.addGoal(title, current, target, unit);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ADD GOAL',
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(
      BuildContext context, FitnessProvider provider, int index) {
    final goal = provider.goals[index];
    final currentCtrl = TextEditingController(text: goal.current.toString());
    final targetCtrl = TextEditingController(text: goal.target.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'EDIT GOAL',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Value',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final current = double.tryParse(currentCtrl.text.trim()) ?? goal.current;
                        final target = double.tryParse(targetCtrl.text.trim()) ?? goal.target;

                        provider.updateGoal(index, current, target);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'SAVE CHANGES',
                        style: GoogleFonts.barlow(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.deleteGoal(index);
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'DELETE',
                        style: GoogleFonts.barlow(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, FitnessProvider provider, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Goal?'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteGoal(index);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}