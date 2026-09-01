import 'package:flutter/material.dart';
import '../app/theme.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIconData(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant_menu_rounded;
      case 'free_breakfast':
        return Icons.free_breakfast_rounded;
      case 'lunch_dining':
        return Icons.lunch_dining_rounded;
      case 'dinner_dining':
        return Icons.dinner_dining_rounded;
      case 'icecream':
        return Icons.icecream_rounded;
      case 'timer':
        return Icons.timer_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconData(iconName),
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
