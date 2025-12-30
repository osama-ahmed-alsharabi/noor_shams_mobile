import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import '../../domain/entities/channel_entity.dart';
import '../cubit/channel_cubit.dart';
import '../cubit/channel_state.dart';
import '../cubit/offer_cubit.dart';
import '../cubit/offer_state.dart';
import '../widgets/channel_card.dart';
import '../widgets/offer_card.dart';
import '../widgets/provider_background.dart';
import 'channel_create_view.dart';
import 'offer_create_view.dart';

class MyServicesView extends StatefulWidget {
  const MyServicesView({super.key});

  @override
  State<MyServicesView> createState() => _MyServicesViewState();
}

class _MyServicesViewState extends State<MyServicesView> {
  @override
  void initState() {
    super.initState();
    context.read<ChannelCubit>().loadChannels();
    context.read<OfferCubit>().loadOffers();
  }

  void _navigateToCreateChannel({
    String? channelId,
    String? name,
    String? description,
  }) {
    final channelCubit = context.read<ChannelCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: channelCubit,
          child: ChannelCreateView(
            channelId: channelId,
            initialName: name,
            initialDescription: description,
          ),
        ),
      ),
    );
  }

  void _navigateToCreateOffer(String channelId) {
    final offerCubit = context.read<OfferCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: offerCubit,
          child: OfferCreateView(channelId: channelId),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف $title؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
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
                  title: const Text('خدماتي'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  titleTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => _navigateToCreateChannel(),
                      icon: const Icon(Icons.add, color: AppColors.primaryBlue),
                      tooltip: 'إضافة قناة',
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<ChannelCubit>().loadChannels();
                      context.read<OfferCubit>().loadOffers();
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChannelsSection(),
                          const SizedBox(height: 24),
                          _buildOffersSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<ChannelCubit, ChannelState>(
        builder: (context, state) {
          // Only show FAB if there are channels
          if (state is ChannelsLoaded && state.channels.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddOfferDialog(state.channels),
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'إضافة عرض',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddOfferDialog(List<ChannelEntity> channels) {
    if (channels.length == 1) {
      // If only one channel, navigate directly
      _navigateToCreateOffer(channels.first.id);
    } else {
      // Show channel selection dialog
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (dialogContext) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر القناة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أي قناة تريد إضافة العرض إليها؟',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              ...channels.map(
                (channel) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: channel.coverImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              channel.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.store,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          )
                        : const Icon(Icons.store, color: AppColors.primaryBlue),
                  ),
                  title: Text(
                    channel.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _navigateToCreateOffer(channel.id);
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildChannelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'قنواتي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _navigateToCreateChannel(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<ChannelCubit, ChannelState>(
          builder: (context, state) {
            if (state is ChannelLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              );
            }

            if (state is ChannelsLoaded) {
              if (state.channels.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.store_outlined,
                  message: 'لم تقم بإنشاء أي قناة بعد',
                  buttonText: 'إنشاء قناة',
                  onPressed: () => _navigateToCreateChannel(),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.channels.length,
                  itemBuilder: (context, index) {
                    final channel = state.channels[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 8,
                        right: index == state.channels.length - 1 ? 0 : 8,
                      ),
                      child: SizedBox(
                        width: 280,
                        child: ChannelCard(
                          channel: channel,
                          onTap: () {
                            // Could navigate to channel details
                          },
                          onToggleStatus: () {
                            context.read<ChannelCubit>().toggleChannelStatus(
                              channel.id,
                              !channel.isActive,
                            );
                          },
                          onEdit: () => _navigateToCreateChannel(
                            channelId: channel.id,
                            name: channel.name,
                            description: channel.description,
                          ),
                          onDelete: () => _showDeleteConfirmation(
                            'القناة "${channel.name}"',
                            () => context.read<ChannelCubit>().deleteChannel(
                              channel.id,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            if (state is ChannelError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عروضي',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<OfferCubit, OfferState>(
          builder: (context, state) {
            if (state is OfferLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              );
            }

            if (state is OffersLoaded) {
              if (state.offers.isEmpty) {
                return BlocBuilder<ChannelCubit, ChannelState>(
                  builder: (context, channelState) {
                    final hasChannels =
                        channelState is ChannelsLoaded &&
                        channelState.channels.isNotEmpty;

                    return _buildEmptyState(
                      icon: Icons.local_offer_outlined,
                      message: hasChannels
                          ? 'لم تقم بإضافة أي عرض بعد'
                          : 'أنشئ قناة أولاً ثم أضف عروضك',
                      buttonText: hasChannels ? 'إضافة عرض' : null,
                      onPressed: hasChannels
                          ? () {
                              final channels = channelState.channels;
                              if (channels.length == 1) {
                                _navigateToCreateOffer(channels.first.id);
                              } else {
                                _showChannelPicker(channels);
                              }
                            }
                          : null,
                    );
                  },
                );
              }

              return Column(
                children: state.offers.map((offer) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OfferCard(
                      offer: offer,
                      onToggleStatus: () {
                        context.read<OfferCubit>().toggleOfferStatus(
                          offer.id,
                          !offer.isActive,
                        );
                      },
                      onEdit: () {
                        final offerCubit = context.read<OfferCubit>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: offerCubit,
                              child: OfferCreateView(
                                channelId: offer.channelId,
                                offerId: offer.id,
                                initialTitle: offer.title,
                                initialDescription: offer.description,
                                initialPrice: offer.price,
                                initialDurationDays: offer.durationDays,
                              ),
                            ),
                          ),
                        );
                      },
                      onDelete: () => _showDeleteConfirmation(
                        'العرض "${offer.title}"',
                        () => context.read<OfferCubit>().deleteOffer(offer.id),
                      ),
                    ),
                  );
                }).toList(),
              );
            }

            if (state is OfferError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  void _showChannelPicker(List channels) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختر القناة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...channels.map(
              (channel) => ListTile(
                leading: const Icon(Icons.store, color: AppColors.primaryBlue),
                title: Text(channel.name),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCreateOffer(channel.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add, size: 18),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
