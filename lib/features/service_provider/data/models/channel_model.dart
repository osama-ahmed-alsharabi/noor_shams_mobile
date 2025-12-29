import '../../domain/entities/channel_entity.dart';

class ChannelModel extends ChannelEntity {
  const ChannelModel({
    required super.id,
    required super.providerId,
    required super.name,
    super.description,
    super.coverImageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'provider_id': providerId,
      'name': name,
      'description': description,
      'cover_image_url': coverImageUrl,
      'is_active': isActive,
    };
  }

  ChannelModel copyWith({
    String? id,
    String? providerId,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
