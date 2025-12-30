import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../../domain/entities/client_order_entity.dart';
import '../cubit/client_order_cubit.dart';
import '../cubit/client_chat_cubit.dart';
import '../widgets/client_background.dart';
import 'client_chat_view.dart';

class ClientOrderDetailsView extends StatelessWidget {
  final ClientOrderEntity order;

  const ClientOrderDetailsView({super.key, required this.order});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'تفاصيل الطلب',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _statusColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getStatusIcon(),
                                    color: _statusColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'حالة الطلب',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        order.status.arabicName,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Order Info Card
                      _buildInfoCard(
                        title: 'معلومات الطلب',
                        children: [
                          _buildInfoRow(
                            'نوع الطلب',
                            order.isCustom ? 'طلب خاص' : 'طلب عرض',
                          ),
                          if (order.offerTitle != null)
                            _buildInfoRow('العرض', order.offerTitle!),
                          if (order.channelName != null)
                            _buildInfoRow('القناة', order.channelName!),
                          _buildInfoRow(
                            'تاريخ الطلب',
                            DateFormat(
                              'dd/MM/yyyy - HH:mm',
                              'ar',
                            ).format(order.createdAt),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Price Card
                      _buildInfoCard(
                        title: 'التسعير',
                        children: [
                          if (order.offerPrice != null)
                            _buildInfoRow(
                              'سعر العرض',
                              '${order.offerPrice!.toStringAsFixed(0)} ر.ي',
                              valueColor: AppColors.textSecondary,
                            ),
                          if (order.proposedPrice != null)
                            _buildInfoRow(
                              'السعر المقترح',
                              '${order.proposedPrice!.toStringAsFixed(0)} ر.ي',
                              valueColor: AppColors.primaryOrange,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Provider Card
                      _buildInfoCard(
                        title: 'مزود الخدمة',
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                ),
                                child: order.providerAvatarUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          order.providerAvatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
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
                                child: Text(
                                  order.providerName ?? 'مزود خدمة',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (order.clientNotes != null &&
                          order.clientNotes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'ملاحظاتك',
                          children: [
                            Text(
                              order.clientNotes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (order.providerNotes != null &&
                          order.providerNotes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'ملاحظات مزود الخدمة',
                          children: [
                            Text(
                              order.providerNotes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Actions
                      if (order.status == ClientOrderStatus.pending ||
                          order.status == ClientOrderStatus.accepted)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (_) =>
                                        ClientChatCubit()..loadChat(order.id),
                                    child: ClientChatView(order: order),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text(
                              'محادثة مزود الخدمة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (order.status == ClientOrderStatus.pending) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => _showCancelDialog(context),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text(
                              'إلغاء الطلب',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
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

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Divider(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ClientOrderCubit>().cancelOrder(order.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }
}
