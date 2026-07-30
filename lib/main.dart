import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/fitness_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/workout_log_screen.dart';
import 'screens/meal_log_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/goals_screen.dart';
import 'widgets/custom_bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FitnessProvider(),
      child: MaterialApp(
        title: 'FitTrack',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        
        home: const MainNavigator(),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();

  static Route<T> slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (ctx, anim, secondAnim) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (ctx, anim, secondAnim, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}

class _MainNavigatorState extends State<MainNavigator> {
  final List<Widget> _screens = const [
    DashboardScreen(),
    WorkoutLogScreen(),
    MealLogScreen(),
    ProgressScreen(),
    GoalsScreen(),
  ];

  void _onTabTap(int index, FitnessProvider provider) {
    if (provider.selectedIndex != index) {
      provider.setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: provider.selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: provider.selectedIndex,
            onTap: (index) => _onTabTap(index, provider),
          ),
        );
      },
    );
  }
}
