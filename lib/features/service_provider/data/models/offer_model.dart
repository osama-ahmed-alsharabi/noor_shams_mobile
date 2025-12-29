import '../../domain/entities/offer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
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
    required super.updatedAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
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
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'channel_id': channelId,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'price': price,
      'duration_days': durationDays,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  OfferModel copyWith({
    String? id,
    String? channelId,
    String? providerId,
    String? title,
    String? description,
    double? price,
    int? durationDays,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
