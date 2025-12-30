import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../cubit/browse_channels_cubit.dart';
import '../cubit/browse_channels_state.dart';
import '../cubit/browse_offers_cubit.dart';
import '../widgets/client_background.dart';
import '../widgets/channel_browse_card.dart';
import '../widgets/search_bar_widget.dart';
import 'channel_details_view.dart';

class BrowseChannelsView extends StatefulWidget {
  const BrowseChannelsView({super.key});

  @override
  State<BrowseChannelsView> createState() => _BrowseChannelsViewState();
}

class _BrowseChannelsViewState extends State<BrowseChannelsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'استكشف القنوات',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تصفح جميع مزودي الخدمات',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomSearchBar(
                    controller: _searchController,
                    hintText: 'ابحث عن قناة...',
                    showFilter: false,
                    onChanged: (query) {
                      context.read<BrowseChannelsCubit>().searchChannels(query);
                    },
                  ),
                ],
              ),
            ),
            // Channels List
            Expanded(
              child: BlocBuilder<BrowseChannelsCubit, BrowseChannelsState>(
                builder: (context, state) {
                  if (state is BrowseChannelsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  if (state is BrowseChannelsLoaded) {
                    if (state.channels.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.searchQuery != null
                                  ? 'لا توجد نتائج للبحث'
                                  : 'لا توجد قنوات متاحة',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          context.read<BrowseChannelsCubit>().loadChannels(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: state.channels.length,
                        itemBuilder: (context, index) {
                          final channel = state.channels[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ChannelBrowseCard(
                              channel: channel,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<BrowseOffersCubit>(),
                                      child: ChannelDetailsView(
                                        channel: channel,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (state is BrowseChannelsError) {
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
                            onPressed: () => context
                                .read<BrowseChannelsCubit>()
                                .loadChannels(),
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
}
