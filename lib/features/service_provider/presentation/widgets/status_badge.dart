import 'package:flutter/material.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isLarge;

  const StatusBadge({super.key, required this.status, this.isLarge = false});

  Color get _backgroundColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.withOpacity(0.15);
      case OrderStatus.accepted:
        return AppColors.primaryBlue.withOpacity(0.15);
      case OrderStatus.rejected:
        return Colors.red.withOpacity(0.15);
      case OrderStatus.completed:
        return AppColors.primaryGreen.withOpacity(0.15);
      case OrderStatus.cancelled:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color get _textColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade700;
      case OrderStatus.accepted:
        return AppColors.primaryBlue;
      case OrderStatus.rejected:
        return Colors.red.shade700;
      case OrderStatus.completed:
        return AppColors.primaryGreen;
      case OrderStatus.cancelled:
        return Colors.grey.shade700;
    }
  }

  IconData get _icon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.accepted:
        return Icons.check_circle_outline;
      case OrderStatus.rejected:
        return Icons.cancel_outlined;
      case OrderStatus.completed:
        return Icons.task_alt;
      case OrderStatus.cancelled:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: isLarge ? 18 : 14, color: _textColor),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: _textColor,
              fontSize: isLarge ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
