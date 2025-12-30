import '../../domain/entities/client_order_entity.dart';

class ClientOrderModel extends ClientOrderEntity {
  const ClientOrderModel({
    required super.id,
    super.offerId,
    required super.channelId,
    required super.clientId,
    required super.providerId,
    required super.status,
    super.proposedPrice,
    super.clientNotes,
    super.providerNotes,
    required super.isCustom,
    required super.createdAt,
    required super.updatedAt,
    super.offerTitle,
    super.offerPrice,
    super.channelName,
    super.providerName,
    super.providerAvatarUrl,
  });

  factory ClientOrderModel.fromJson(Map<String, dynamic> json) {
    // Handle joined offer data
    final offer = json['offer'] as Map<String, dynamic>?;
    // Handle joined channel data
    final channel = json['channel'] as Map<String, dynamic>?;
    // Handle joined provider data
    final provider = json['provider'] as Map<String, dynamic>?;

    return ClientOrderModel(
      id: json['id'] as String,
      offerId: json['offer_id'] as String?,
      channelId: json['channel_id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String,
      status: ClientOrderStatus.fromString(
        json['status'] as String? ?? 'pending',
      ),
      proposedPrice: json['proposed_price'] != null
          ? (json['proposed_price'] as num).toDouble()
          : null,
      clientNotes: json['client_notes'] as String?,
      providerNotes: json['provider_notes'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      offerTitle: offer?['title'] as String?,
      offerPrice: offer?['price'] != null
          ? (offer!['price'] as num).toDouble()
          : null,
      channelName: channel?['name'] as String?,
      providerName: provider?['name'] as String?,
      providerAvatarUrl: provider?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offer_id': offerId,
      'channel_id': channelId,
      'client_id': clientId,
      'provider_id': providerId,
      'status': status.name,
      'proposed_price': proposedPrice,
      'client_notes': clientNotes,
      'provider_notes': providerNotes,
      'is_custom': isCustom,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create insert data for new order
  static Map<String, dynamic> createOrderData({
    required String offerId,
    required String channelId,
    required String clientId,
    required String providerId,
    String? clientNotes,
    double? proposedPrice,
  }) {
    return {
      'offer_id': offerId,
      'channel_id': channelId,
      'client_id': clientId,
      'provider_id': providerId,
      'client_notes': clientNotes,
      'proposed_price': proposedPrice,
      'is_custom': false,
      'status': 'pending',
    };
  }

  /// Create insert data for custom order
  static Map<String, dynamic> createCustomOrderData({
    required String channelId,
    required String clientId,
    required String providerId,
    required String clientNotes,
    double? proposedPrice,
  }) {
    return {
      'channel_id': channelId,
      'client_id': clientId,
      'provider_id': providerId,
      'client_notes': clientNotes,
      'proposed_price': proposedPrice,
      'is_custom': true,
      'status': 'pending',
    };
  }
}
