import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors.dart';

class AuthSwitchRow extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const AuthSwitchRow({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(color: AppColors.textPrimary.withOpacity(0.7)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
