import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/widgets/loading_overlay.dart';
import '../cubit/client_home_cubit.dart';
import '../cubit/client_home_state.dart';
import '../cubit/browse_offers_cubit.dart';
import '../widgets/client_background.dart';
import '../widgets/channel_browse_card.dart';
import '../widgets/offer_browse_card.dart';
import '../widgets/search_bar_widget.dart';
import 'channel_details_view.dart';
import 'offer_details_view.dart';

class ClientHomeView extends StatelessWidget {
  const ClientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientHomeCubit, ClientHomeState>(
      builder: (context, state) {
        final isLoading = state is ClientHomeLoading;

        return LoadingOverlay(
          isLoading: isLoading,
          child: ClientBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<ClientHomeCubit>().refresh(),
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مرحباً بك! 👋',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'ابحث عن خدمتك',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Search Bar
                            CustomSearchBar(
                              hintText: 'ابحث عن خدمة أو عرض...',
                              showFilter: false,
                              onChanged: (query) {
                                if (query.isNotEmpty) {
                                  context
                                      .read<BrowseOffersCubit>()
                                      .searchOffers(query);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Stats Cards
                    if (state is ClientHomeLoaded) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buildStatCard(
                                'الطلبات',
                                '${state.orderStats['total'] ?? 0}',
                                Icons.receipt_long_outlined,
                                AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'قيد الانتظار',
                                '${state.orderStats['pending'] ?? 0}',
                                Icons.access_time,
                                AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'مكتملة',
                                '${state.orderStats['completed'] ?? 0}',
                                Icons.task_alt,
                                AppColors.primaryGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      // Featured Channels
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'القنوات المميزة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to browse channels
                                },
                                child: const Text('عرض الكل'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 260,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.featuredChannels.length,
                            itemBuilder: (context, index) {
                              final channel = state.featuredChannels[index];
                              return Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: SizedBox(
                                  width: 240,
                                  child: ChannelBrowseCard(
                                    channel: channel,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context
                                                .read<BrowseOffersCubit>(),
                                            child: ChannelDetailsView(
                                              channel: channel,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      // Featured Offers
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'أحدث العروض',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to browse offers
                                },
                                child: const Text('عرض الكل'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final offer = state.featuredOffers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OfferBrowseCard(
                                offer: offer,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OfferDetailsView(offer: offer),
                                    ),
                                  );
                                },
                              ),
                            );
                          }, childCount: state.featuredOffers.length),
                        ),
                      ),
                    ] else if (state is ClientHomeError) ...[
                      SliverFillRemaining(
                        child: Center(
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
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<ClientHomeCubit>()
                                    .loadHomeData(),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
