import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleSelected;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تسجيل الدخول كـ :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRoleButton('عميل', 'client')),
            const SizedBox(width: 15),
            Expanded(child: _buildRoleButton('مزود خدمة', 'provider')),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleButton(String title, String value) {
    bool isSelected = selectedRole == value;
    return GestureDetector(
      onTap: () => onRoleSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withOpacity(0.2)
              : Colors.white.withOpacity(0.5),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primaryOrange
                  : AppColors.textPrimary.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
