import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
        icon: Icons.fitness_center_outlined,
        activeIcon: Icons.fitness_center,
        label: 'Workout'),
    _NavItem(
        icon: Icons.restaurant_outlined,
        activeIcon: Icons.restaurant,
        label: 'Meals'),
    _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Progress'),
    _NavItem(
        icon: Icons.flag_outlined, activeIcon: Icons.flag, label: 'Goals'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _items.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Sliding indicator bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                left: selectedIndex * itemWidth,
                top: 0,
                width: itemWidth,
                height: 2,
                child: Container(
                  color: AppColors.accent,
                ),
              ),
              // Nav items
              Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final isActive = selectedIndex == index;
                  return _NavItemWidget(
                    item: item,
                    isActive: isActive,
                    width: itemWidth,
                    onTap: () => onTap(index),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final double width;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive ? AppColors.accent : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.accent : AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
