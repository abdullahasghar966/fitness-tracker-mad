import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
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
              // Overall progress header with left accent strip.
              // Flutter forbids borderRadius + non-uniform border widths, so we
              // use the shared pattern: outer uniform-border container +
              // inner ClipRRect row with a 4px accent strip.
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: provider
                                              .overallGoalProgress
                                              .clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.accent,
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                        ),
                      ],
                    ),
                  ),
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
                child: provider.goals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flag_outlined,
                                  size: 40, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                'NO GOALS YET',
                                style: GoogleFonts.barlowCondensed(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add a goal to start tracking progress',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: provider.goals.length,
                        itemBuilder: (context, index) {
                          final goal = provider.goals[index];

                          return VolumeListItem(
                            scrollController: _scrollCtrl,
                            revealDelay: Duration(milliseconds: index * 80),
                            child: GoalCard(
                              goal: goal,
                              // Guarded against a zero target.
                              progress: goal.progress,
                              onEdit: () =>
                                  _showEditDialog(context, provider, index),
                              onDelete: () =>
                                  _showDeleteDialog(context, provider, index),
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

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final provider = context.read<FitnessProvider>();

    final result = await showModalBottomSheet<_GoalDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _GoalSheet(),
    );
    if (result == null) return;

    provider.addGoal(
      result.title,
      result.current,
      result.target,
      result.unit,
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, FitnessProvider provider, int index) async {
    if (index < 0 || index >= provider.goals.length) return;
    final goal = provider.goals[index];

    final result = await showModalBottomSheet<_GoalDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _GoalSheet(goal: goal),
    );
    if (result == null) return;

    if (result.delete) {
      provider.deleteGoal(index);
    } else {
      provider.updateGoal(index, result.current, result.target);
    }
  }

  void _showDeleteDialog(
      BuildContext context, FitnessProvider provider, int index) {
    if (index < 0 || index >= provider.goals.length) return;
    final title = provider.goals[index].title;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'DELETE GOAL?',
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$title"?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Goal sheet
//
// One StatefulWidget serves both add and edit so it can own — and dispose —
// its controllers. Disposing right after `await showModalBottomSheet` would
// risk a "used after being disposed" error while the sheet animates out.
// ─────────────────────────────────────────────────────────────────────────────

class _GoalDraft {
  final String title;
  final double current;
  final double target;
  final String unit;
  final bool delete;

  const _GoalDraft({
    this.title = '',
    this.current = 0,
    this.target = 0,
    this.unit = '',
    this.delete = false,
  });
}

class _GoalSheet extends StatefulWidget {
  /// Null for add mode; an existing goal switches the sheet to edit mode.
  final Goal? goal;

  const _GoalSheet({this.goal});

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _currentCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _unitCtrl;

  String? _titleError;
  String? _currentError;
  String? _targetError;

  bool get _isEdit => widget.goal != null;

  static String _num(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleCtrl = TextEditingController(text: goal?.title ?? '');
    _currentCtrl =
        TextEditingController(text: goal == null ? '' : _num(goal.current));
    _targetCtrl =
        TextEditingController(text: goal == null ? '' : _num(goal.target));
    _unitCtrl = TextEditingController(text: goal?.unit ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _currentCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final currentText = _currentCtrl.text.trim();
    final targetText = _targetCtrl.text.trim();

    // An empty "current" means starting from zero.
    final current = currentText.isEmpty ? 0.0 : double.tryParse(currentText);
    final target = double.tryParse(targetText);

    setState(() {
      // Title is fixed while editing, so it can't be invalid there.
      _titleError =
          (!_isEdit && title.isEmpty) ? 'Enter a goal title' : null;
      _currentError = (current == null || current < 0)
          ? 'Enter 0 or more'
          : null;
      _targetError = (target == null || target <= 0)
          ? 'Enter a target greater than 0'
          : null;
    });

    if (!_isEdit && title.isEmpty) return;
    if (current == null || current < 0) return;
    if (target == null || target <= 0) return;

    Navigator.pop(
      context,
      _GoalDraft(
        title: _isEdit ? widget.goal!.title : title,
        current: current,
        target: target,
        unit: _isEdit ? widget.goal!.unit : _unitCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _isEdit ? 'EDIT GOAL' : 'ADD NEW GOAL',
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title is only editable when creating a goal.
          if (!_isEdit) ...[
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 8),
          ],

          TextField(
            controller: _currentCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Current Value',
              errorText: _currentError,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _targetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: _isEdit
                ? TextInputAction.done
                : TextInputAction.next,
            onSubmitted: _isEdit ? (_) => _submit() : null,
            decoration: InputDecoration(
              labelText: 'Target Value',
              errorText: _targetError,
            ),
          ),

          if (!_isEdit) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _unitCtrl,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Unit (kg, cm, etc.)',
              ),
            ),
          ],

          const SizedBox(height: 20),

          if (_isEdit)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
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
                    onPressed: () => Navigator.pop(
                      context,
                      const _GoalDraft(delete: true),
                    ),
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
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
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
  }
}