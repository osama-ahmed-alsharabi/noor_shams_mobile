import 'package:flutter/material.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<FilterOption> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const FilterChipsWidget({
    super.key,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selectedValue == option.value;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) => onSelected(isSelected ? null : option.value),
              backgroundColor: Colors.white.withOpacity(0.8),
              selectedColor: AppColors.primaryBlue.withOpacity(0.15),
              labelStyle: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              checkmarkColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryBlue.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final String value;

  const FilterOption({required this.label, required this.value});
}

/// Predefined sort options
class SortOptions {
  static const List<FilterOption> offers = [
    FilterOption(label: 'الأحدث', value: 'newest'),
    FilterOption(label: 'الأقل سعراً', value: 'price_asc'),
    FilterOption(label: 'الأعلى سعراً', value: 'price_desc'),
    FilterOption(label: 'الأسرع تنفيذاً', value: 'duration'),
  ];
}
