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

  void _showMealDialog(FitnessProvider provider, {Meal? meal}) async {
    final nameController = TextEditingController(text: meal?.name ?? '');
    final caloriesController =
    TextEditingController(text: meal?.calories.toString() ?? '');
    final proteinController =
    TextEditingController(text: meal?.protein.toString() ?? '');
    final carbsController =
    TextEditingController(text: meal?.carbs.toString() ?? '');
    final fatController =
    TextEditingController(text: meal?.fat.toString() ?? '');
    String category = meal?.category ?? 'Breakfast';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(meal == null ? 'Add New Meal' : 'Edit Meal'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Meal Name'),
                ),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calories'),
                ),
                TextField(
                  controller: proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                ),
                TextField(
                  controller: carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Carbs (g)'),
                ),
                TextField(
                  controller: fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Fat (g)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ))
                      .toList(),
                  onChanged: (v) => category = v ?? 'Breakfast',
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            if (meal != null)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, {"action": "delete"}),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;

                final newMeal = Meal(
                  name: nameController.text,
                  category: category,
                  calories: int.tryParse(caloriesController.text) ?? 0,
                  protein: double.tryParse(proteinController.text) ?? 0.0,
                  carbs: double.tryParse(carbsController.text) ?? 0.0,
                  fat: double.tryParse(fatController.text) ?? 0.0,
                );

                Navigator.pop(dialogContext, {"action": "save", "meal": newMeal});
              },
              child: Text(meal == null ? 'Add Meal' : 'Save Changes'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      if (result["action"] == "delete") {
        provider.deleteMeal(meal!);
      } else if (result["action"] == "save") {
        if (meal == null) {
          provider.addMeal(result["meal"] as Meal);
        } else {
          provider.editMeal(meal, result["meal"] as Meal);
        }
      }
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