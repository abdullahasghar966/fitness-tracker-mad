import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final double progress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.progress,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Trust the caller's value, but keep it in range — it drives both the
    // badge and the bar so the two can never disagree.
    final safeProgress = progress.clamp(0.0, 1.0);
    final percent = (safeProgress * 100).toStringAsFixed(0);

    // FIX: Flutter throws "A borderRadius can only be given for uniform borders"
    // when mixing border widths (left: 4px, others: 1px) with borderRadius.
    // Solution: outer container = uniform 1px border + borderRadius,
    // inner ClipRRect + Row = 4px accent strip on the left.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              // Left accent strip
              Container(width: 4, color: AppColors.accent),
              // Card body
              Expanded(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(goal.icon, size: 20, color: AppColors.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: GoogleFonts.barlowCondensed(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  goal.subtitle,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.accent, width: 1),
                            ),
                            child: Text(
                              '$percent%',
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: safeProgress,
                          minHeight: 6,
                          backgroundColor: AppColors.divider,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${goal.current % 1 == 0 ? goal.current.toInt() : goal.current}',
                                  style: GoogleFonts.barlowCondensed(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' / ${goal.target % 1 == 0 ? goal.target.toInt() : goal.target} ${goal.unit}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.accent, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'EDIT',
                                style: GoogleFonts.barlow(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          if (onDelete != null)
                            GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.red, width: 1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'DELETE',
                                  style: GoogleFonts.barlow(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
