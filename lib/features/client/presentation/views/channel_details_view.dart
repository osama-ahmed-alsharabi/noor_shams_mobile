import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../../domain/entities/client_channel_entity.dart';
import '../cubit/browse_offers_cubit.dart';
import '../cubit/browse_offers_state.dart';
import '../widgets/client_background.dart';
import '../widgets/offer_browse_card.dart';
import '../widgets/filter_chips_widget.dart';
import 'offer_details_view.dart';

class ChannelDetailsView extends StatefulWidget {
  final ClientChannelEntity channel;

  const ChannelDetailsView({super.key, required this.channel});

  @override
  State<ChannelDetailsView> createState() => _ChannelDetailsViewState();
}

class _ChannelDetailsViewState extends State<ChannelDetailsView> {
  String? _sortBy;

  @override
  void initState() {
    super.initState();
    context.read<BrowseOffersCubit>().loadOffers(channelId: widget.channel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClientBackground(
        child: CustomScrollView(
          slivers: [
            // App Bar with Cover Image
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: widget.channel.coverImageUrl != null
                    ? Image.network(
                        widget.channel.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                      )
                    : _buildCoverPlaceholder(),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Channel Info
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: widget.channel.providerAvatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    widget.channel.providerAvatarUrl!,
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
                                widget.channel.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                widget.channel.providerName ?? 'مزود خدمة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.channel.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.channel.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'العروض المتاحة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        BlocBuilder<BrowseOffersCubit, BrowseOffersState>(
                          builder: (context, state) {
                            if (state is BrowseOffersLoaded) {
                              return Text(
                                '${state.offers.length} عرض',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.7,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Sort Chips
                    FilterChipsWidget(
                      options: SortOptions.offers,
                      selectedValue: _sortBy,
                      onSelected: (value) {
                        setState(() => _sortBy = value);
                        if (value != null) {
                          context.read<BrowseOffersCubit>().sortOffers(value);
                        } else {
                          context.read<BrowseOffersCubit>().loadOffers(
                            channelId: widget.channel.id,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Offers List
            BlocBuilder<BrowseOffersCubit, BrowseOffersState>(
              builder: (context, state) {
                if (state is BrowseOffersLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  );
                }

                if (state is BrowseOffersLoaded) {
                  if (state.offers.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد عروض متاحة',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final offer = state.offers[index];
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
                      }, childCount: state.offers.length),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: AppColors.primaryBlue,
      child: Center(
        child: Icon(
          Icons.store,
          size: 80,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
