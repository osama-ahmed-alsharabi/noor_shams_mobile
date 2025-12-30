import 'package:equatable/equatable.dart';

/// Offer entity for client browsing
class ClientOfferEntity extends Equatable {
  final String id;
  final String channelId;
  final String providerId;
  final String title;
  final String? description;
  final double price;
  final int? durationDays;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  // Channel info (joined)
  final String? channelName;
  final String? channelCoverUrl;

  // Provider info (joined)
  final String? providerName;
  final String? providerAvatarUrl;

  const ClientOfferEntity({
    required this.id,
    required this.channelId,
    required this.providerId,
    required this.title,
    this.description,
    required this.price,
    this.durationDays,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.channelName,
    this.channelCoverUrl,
    this.providerName,
    this.providerAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    channelId,
    providerId,
    title,
    description,
    price,
    durationDays,
    imageUrl,
    isActive,
    createdAt,
    channelName,
    channelCoverUrl,
    providerName,
    providerAvatarUrl,
  ];
}
