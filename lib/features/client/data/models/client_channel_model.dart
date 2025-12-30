import '../../domain/entities/client_channel_entity.dart';

class ClientChannelModel extends ClientChannelEntity {
  const ClientChannelModel({
    required super.id,
    required super.providerId,
    required super.name,
    super.description,
    super.coverImageUrl,
    required super.isActive,
    required super.createdAt,
    super.providerName,
    super.providerAvatarUrl,
  });

  factory ClientChannelModel.fromJson(Map<String, dynamic> json) {
    // Handle joined provider data
    final provider = json['provider'] as Map<String, dynamic>?;

    return ClientChannelModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      providerName: provider?['name'] as String?,
      providerAvatarUrl: provider?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'name': name,
      'description': description,
      'cover_image_url': coverImageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
