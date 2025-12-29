import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
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
    super.clientName,
    super.offerTitle,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle joined client data
    String? clientName;
    if (json['client'] != null && json['client'] is Map) {
      clientName = json['client']['name'] as String?;
    }

    // Handle joined offer data
    String? offerTitle;
    if (json['offer'] != null && json['offer'] is Map) {
      offerTitle = json['offer']['title'] as String?;
    }

    return OrderModel(
      id: json['id'] as String,
      offerId: json['offer_id'] as String?,
      channelId: json['channel_id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String,
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      proposedPrice: json['proposed_price'] != null
          ? (json['proposed_price'] as num).toDouble()
          : null,
      clientNotes: json['client_notes'] as String?,
      providerNotes: json['provider_notes'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      clientName: clientName,
      offerTitle: offerTitle,
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
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'offer_id': offerId,
      'channel_id': channelId,
      'client_id': clientId,
      'provider_id': providerId,
      'status': status.name,
      'proposed_price': proposedPrice,
      'client_notes': clientNotes,
      'is_custom': isCustom,
    };
  }

  OrderModel copyWith({
    String? id,
    String? offerId,
    String? channelId,
    String? clientId,
    String? providerId,
    OrderStatus? status,
    double? proposedPrice,
    String? clientNotes,
    String? providerNotes,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? clientName,
    String? offerTitle,
  }) {
    return OrderModel(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      channelId: channelId ?? this.channelId,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      clientNotes: clientNotes ?? this.clientNotes,
      providerNotes: providerNotes ?? this.providerNotes,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientName: clientName ?? this.clientName,
      offerTitle: offerTitle ?? this.offerTitle,
    );
  }
}
