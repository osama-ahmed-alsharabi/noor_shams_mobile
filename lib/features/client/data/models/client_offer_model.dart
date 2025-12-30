import '../../domain/entities/client_offer_entity.dart';

class ClientOfferModel extends ClientOfferEntity {
  const ClientOfferModel({
    required super.id,
    required super.channelId,
    required super.providerId,
    required super.title,
    super.description,
    required super.price,
    super.durationDays,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    super.channelName,
    super.channelCoverUrl,
    super.providerName,
    super.providerAvatarUrl,
  });

  factory ClientOfferModel.fromJson(Map<String, dynamic> json) {
    // Handle joined channel data
    final channel = json['channel'] as Map<String, dynamic>?;
    // Handle joined provider data
    final provider = json['provider'] as Map<String, dynamic>?;

    return ClientOfferModel(
      id: json['id'] as String,
      channelId: json['channel_id'] as String,
      providerId: json['provider_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      durationDays: json['duration_days'] as int?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      channelName: channel?['name'] as String?,
      channelCoverUrl: channel?['cover_image_url'] as String?,
      providerName: provider?['name'] as String?,
      providerAvatarUrl: provider?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'price': price,
      'duration_days': durationDays,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
