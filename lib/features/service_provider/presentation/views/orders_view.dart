import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../widgets/order_card.dart';
import '../widgets/provider_background.dart';
import 'order_details_view.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<OrderCubit>().loadProviderOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return orders; // All orders
      case 1:
        return orders.where((o) => o.status == OrderStatus.pending).toList();
      case 2:
        return orders.where((o) => o.status == OrderStatus.accepted).toList();
      case 3:
        return orders
            .where(
              (o) =>
                  o.status == OrderStatus.completed ||
                  o.status == OrderStatus.rejected,
            )
            .toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ProviderBackground(),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text('الطلبات'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  automaticallyImplyLeading: false,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryBlue,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'الكل'),
                      Tab(text: 'جديدة'),
                      Tab(text: 'نشطة'),
                      Tab(text: 'مكتملة'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<OrderCubit, OrderState>(
                    builder: (context, state) {
                      if (state is OrderLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        );
                      }

                      if (state is OrderError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<OrderCubit>()
                                      .loadProviderOrders();
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is OrdersLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: List.generate(4, (index) {
                            final filteredOrders = _filterOrders(
                              state.orders,
                              index,
                            );

                            if (filteredOrders.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد طلبات',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<OrderCubit>().loadProviderOrders();
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, i) {
                                  final order = filteredOrders[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: OrderCard(
                                      order: order,
                                      onTap: () {
                                        final orderCubit = context
                                            .read<OrderCubit>();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: orderCubit,
                                              child: OrderDetailsView(
                                                orderId: order.id,
                                              ),
                                            ),
                                          ),
                                        ).then((_) {
                                          if (context.mounted) {
                                            context
                                                .read<OrderCubit>()
                                                .loadProviderOrders();
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
