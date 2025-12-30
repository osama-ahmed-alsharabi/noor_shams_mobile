import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../cubit/client_order_cubit.dart';
import '../cubit/client_order_state.dart';
import '../cubit/client_chat_cubit.dart';
import '../../domain/entities/client_order_entity.dart';
import '../widgets/client_background.dart';
import '../widgets/client_order_card.dart';
import 'client_chat_view.dart';
import 'client_order_details_view.dart';

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(text: 'الكل'),
    Tab(text: 'قيد الانتظار'),
    Tab(text: 'مقبولة'),
    Tab(text: 'مكتملة'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ClientOrderEntity> _filterOrders(
    List<ClientOrderEntity> orders,
    int tabIndex,
  ) {
    switch (tabIndex) {
      case 1:
        return orders
            .where((o) => o.status == ClientOrderStatus.pending)
            .toList();
      case 2:
        return orders
            .where((o) => o.status == ClientOrderStatus.accepted)
            .toList();
      case 3:
        return orders
            .where((o) => o.status == ClientOrderStatus.completed)
            .toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'طلباتي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.read<ClientOrderCubit>().loadOrders(),
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: _tabs,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primaryBlue,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Orders List
            Expanded(
              child: BlocBuilder<ClientOrderCubit, ClientOrderState>(
                builder: (context, state) {
                  if (state is ClientOrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  if (state is ClientOrdersLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: List.generate(_tabs.length, (tabIndex) {
                        final filteredOrders = _filterOrders(
                          state.orders,
                          tabIndex,
                        );

                        if (filteredOrders.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 80,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد طلبات',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () =>
                              context.read<ClientOrderCubit>().loadOrders(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClientOrderCard(
                                  order: order,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context
                                              .read<ClientOrderCubit>(),
                                          child: ClientOrderDetailsView(
                                            order: order,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onCancel: () {
                                    _showCancelDialog(order);
                                  },
                                  onChat: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (_) =>
                                              ClientChatCubit()
                                                ..loadChat(order.id),
                                          child: ClientChatView(order: order),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    );
                  }

                  if (state is ClientOrderError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ClientOrderCubit>().loadOrders(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(ClientOrderEntity order) {
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }
}
