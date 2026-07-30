import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/macro_progress_bar.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/volume_scroll_list.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    _fabController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _showMealDialog(FitnessProvider provider, {Meal? meal}) async {
    final result = await showDialog<_MealResult>(
      context: context,
      builder: (_) => _MealDialog(meal: meal),
    );
    if (result == null) return;

    if (result.delete) {
      provider.deleteMeal(meal!);
    } else if (meal == null) {
      provider.addMeal(result.meal!);
    } else {
      provider.editMeal(meal, result.meal!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'MEAL LOG',
          style: GoogleFonts.barlowCondensed(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () {},
            color: AppColors.textPrimary,
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            final provider =
            Provider.of<FitnessProvider>(context, listen: false);
            _showMealDialog(provider);
          },
          backgroundColor: AppColors.accent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          return VolumeScrollList(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            children: [
              // Macro Summary Circles
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
                      'TODAY\'S NUTRITION',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircularProgressWidget(
                          progress: provider.totalCalories / 2000,
                          size: 80,
                          strokeWidth: 7,
                          color: AppColors.accentRed,
                          label: 'CALORIES',
                          value: '${provider.totalCalories}',
                          unit: 'kcal',
                        ),
                        CircularProgressWidget(
                          progress: provider.totalProtein / 150,
                          size: 80,
                          strokeWidth: 7,
                          color: const Color(0xFF4ECDC4),
                          label: 'PROTEIN',
                          value: '${provider.totalProtein.toInt()}',
                          unit: 'g',
                        ),
                        CircularProgressWidget(
                          progress: provider.totalCarbs / 220,
                          size: 80,
                          strokeWidth: 7,
                          color: const Color(0xFFFFB347),
                          label: 'CARBS',
                          value: '${provider.totalCarbs.toInt()}',
                          unit: 'g',
                        ),
                        CircularProgressWidget(
                          progress: provider.totalFat / 65,
                          size: 80,
                          strokeWidth: 7,
                          color: const Color(0xFFFF6B35),
                          label: 'FAT',
                          value: '${provider.totalFat.toInt()}',
                          unit: 'g',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Macro Progress Bars
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
                      'MACRO TARGETS',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MacroProgressBar(
                      label: 'Protein',
                      current: provider.totalProtein,
                      target: 150,
                      color: const Color(0xFF4ECDC4),
                      unit: 'g',
                    ),
                    MacroProgressBar(
                      label: 'Carbs',
                      current: provider.totalCarbs,
                      target: 220,
                      color: const Color(0xFFFFB347),
                      unit: 'g',
                    ),
                    MacroProgressBar(
                      label: 'Fat',
                      current: provider.totalFat,
                      target: 65,
                      color: const Color(0xFFFF6B35),
                      unit: 'g',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Meal Sections
              _buildMealSection(
                  'BREAKFAST', provider.breakfastMeals, Icons.wb_sunny_outlined, provider),
              _buildMealSection(
                  'LUNCH', provider.lunchMeals, Icons.wb_cloudy_outlined, provider),
              _buildMealSection(
                  'DINNER', provider.dinnerMeals, Icons.nights_stay_outlined, provider),
              _buildMealSection(
                  'SNACKS', provider.snackMeals, Icons.fastfood_outlined, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMealSection(String title, List<Meal> meals, IconData icon, FitnessProvider provider) {
    if (meals.isEmpty) return const SizedBox.shrink();

    final sectionCalories = meals.fold(0, (sum, m) => sum + m.calories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.barlowCondensed(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Text(
              '$sectionCalories kcal',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...meals.map(
              (meal) => GestureDetector(
            onTap: () => _showMealDialog(provider, meal: meal),
            child: _MealItem(meal: meal),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MealItem extends StatelessWidget {
  final Meal meal;

  const _MealItem({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MacroTag('P: ${meal.protein.toInt()}g',
                        const Color(0xFF4ECDC4)),
                    const SizedBox(width: 8),
                    _MacroTag('C: ${meal.carbs.toInt()}g',
                        const Color(0xFFFFB347)),
                    const SizedBox(width: 8),
                    _MacroTag('F: ${meal.fat.toInt()}g',
                        const Color(0xFFFF6B35)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories}',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'kcal',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroTag extends StatelessWidget {
  final String text;
  final Color color;

  const _MacroTag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meal dialog
//
// A StatefulWidget so it owns — and disposes — its controllers. Disposing
// right after `await showDialog` would risk a "used after being disposed"
// error while the dismissal animation still renders the fields.
// ─────────────────────────────────────────────────────────────────────────────

class _MealResult {
  final Meal? meal;
  final bool delete;

  const _MealResult({this.meal, this.delete = false});
}

class _MealDialog extends StatefulWidget {
  final Meal? meal;

  const _MealDialog({this.meal});

  @override
  State<_MealDialog> createState() => _MealDialogState();
}

class _MealDialogState extends State<_MealDialog> {
  static const _categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _proteinCtrl;
  late final TextEditingController _carbsCtrl;
  late final TextEditingController _fatCtrl;
  late String _category;

  String? _nameError;
  String? _caloriesError;
  String? _macroError;

  bool get _isEdit => widget.meal != null;

  /// Renders whole numbers without a trailing ".0" in the prefilled fields.
  static String _num(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    _nameCtrl = TextEditingController(text: meal?.name ?? '');
    _caloriesCtrl =
        TextEditingController(text: meal == null ? '' : '${meal.calories}');
    _proteinCtrl =
        TextEditingController(text: meal == null ? '' : _num(meal.protein));
    _carbsCtrl =
        TextEditingController(text: meal == null ? '' : _num(meal.carbs));
    _fatCtrl = TextEditingController(text: meal == null ? '' : _num(meal.fat));
    _category = meal?.category ?? 'Breakfast';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  /// Blank macro fields are treated as 0; anything non-numeric or negative
  /// is rejected rather than silently coerced to 0.
  double? _parseMacro(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return 0.0;
    final value = double.tryParse(text);
    if (value == null || value < 0) return null;
    return value;
  }

  void _submit() {
    final name = _nameCtrl.text.trim();

    final caloriesText = _caloriesCtrl.text.trim();
    final calories =
        caloriesText.isEmpty ? 0 : int.tryParse(caloriesText);

    final protein = _parseMacro(_proteinCtrl.text);
    final carbs = _parseMacro(_carbsCtrl.text);
    final fat = _parseMacro(_fatCtrl.text);

    setState(() {
      _nameError = name.isEmpty ? 'Enter a meal name' : null;
      _caloriesError = (calories == null || calories < 0)
          ? 'Enter calories (0 or more)'
          : null;
      _macroError = (protein == null || carbs == null || fat == null)
          ? 'Macros must be numbers of 0 or more'
          : null;
    });

    if (name.isEmpty) return;
    if (calories == null || calories < 0) return;
    if (protein == null || carbs == null || fat == null) return;

    Navigator.pop(
      context,
      _MealResult(
        meal: Meal(
          name: name,
          category: _category,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _isEdit ? 'EDIT MEAL' : 'ADD NEW MEAL',
        style: GoogleFonts.barlowCondensed(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                errorText: _nameError,
              ),
            ),
            TextField(
              controller: _caloriesCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Calories',
                errorText: _caloriesError,
              ),
            ),
            TextField(
              controller: _proteinCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Protein (g)'),
            ),
            TextField(
              controller: _carbsCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Carbs (g)'),
            ),
            TextField(
              controller: _fatCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Fat (g)',
                errorText: _macroError,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Breakfast'),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
      ),
      actions: [
        if (_isEdit)
          TextButton(
            onPressed: () =>
                Navigator.pop(context, const _MealResult(delete: true)),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(_isEdit ? 'SAVE' : 'ADD MEAL'),
        ),
      ],
    );
  }
}