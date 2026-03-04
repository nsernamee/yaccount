import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';

/// 分类选择器组件
class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final String transactionType;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.transactionType,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = DefaultCategories.categories;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isSelected = selectedCategory == category.id;
        return GestureDetector(
          onTap: () => onCategorySelected(category.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(category.colorValue).withValues(alpha: 0.2)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Color(category.colorValue)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(category.colorValue).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    size: 18,
                    color: Color(category.colorValue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected
                        ? Color(category.colorValue)
                        : AppConstants.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.more_horiz;
    }
  }
}

/// 分类图标显示组件
class CategoryIcon extends StatelessWidget {
  final String categoryId;
  final double size;

  const CategoryIcon({
    super.key,
    required this.categoryId,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final category = DefaultCategories.categories
        .where((c) => c.id == categoryId)
        .firstOrNull;

    if (category == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz, size: size * 0.5),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(category.colorValue).withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIconData(category.icon),
        size: size * 0.5,
        color: Color(category.colorValue),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.more_horiz;
    }
  }
}
