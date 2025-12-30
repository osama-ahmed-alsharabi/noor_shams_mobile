import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../../domain/entities/client_order_entity.dart';

class ClientOrderCard extends StatelessWidget {
  final ClientOrderEntity order;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onChat;

  const ClientOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onCancel,
    this.onChat,
  });

  Color get _statusColor {
    switch (order.status) {
      case ClientOrderStatus.pending:
        return AppColors.primaryOrange;
      case ClientOrderStatus.accepted:
        return AppColors.primaryBlue;
      case ClientOrderStatus.completed:
        return AppColors.primaryGreen;
      case ClientOrderStatus.rejected:
        return Colors.red;
      case ClientOrderStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case ClientOrderStatus.pending:
        return Icons.access_time;
      case ClientOrderStatus.accepted:
        return Icons.check_circle_outline;
      case ClientOrderStatus.completed:
        return Icons.task_alt;
      case ClientOrderStatus.rejected:
        return Icons.cancel_outlined;
      case ClientOrderStatus.cancelled:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Provider Avatar
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withOpacity(0.1),
                      ),
                      child: order.providerAvatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                order.providerAvatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.isCustom
                                ? 'طلب خاص'
                                : (order.offerTitle ?? 'طلب'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.providerName ?? 'مزود الخدمة',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon, size: 14, color: _statusColor),
                          const SizedBox(width: 4),
                          Text(
                            order.status.arabicName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (order.clientNotes != null &&
                    order.clientNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    order.clientNotes!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    if (order.proposedPrice != null || order.offerPrice != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(order.proposedPrice ?? order.offerPrice)!.toStringAsFixed(0)} ر.ي',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    // Actions
                    Row(
                      children: [
                        if (order.status == ClientOrderStatus.pending &&
                            onCancel != null)
                          TextButton(
                            onPressed: onCancel,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        if ((order.status == ClientOrderStatus.accepted ||
                                order.status == ClientOrderStatus.pending) &&
                            onChat != null)
                          TextButton.icon(
                            onPressed: onChat,
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                            ),
                            label: const Text(
                              'محادثة',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
