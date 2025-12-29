import '../../domain/entities/service_provider_entity.dart';

class ServiceProviderModel extends ServiceProviderEntity {
  const ServiceProviderModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.profession,
    required super.bio,
    required super.experienceYears,
    required super.portfolioImages,
    required super.rating,
    required super.reviewCount,
    required super.isAvailable,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profession: json['profession'] as String,
      bio: json['bio'] as String,
      experienceYears: json['experienceYears'] as int,
      portfolioImages: List<String>.from(json['portfolioImages'] as List),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      isAvailable: json['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profession': profession,
      'bio': bio,
      'experienceYears': experienceYears,
      'portfolioImages': portfolioImages,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
    };
  }

  factory ServiceProviderModel.fromEntity(ServiceProviderEntity entity) {
    return ServiceProviderModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      profession: entity.profession,
      bio: entity.bio,
      experienceYears: entity.experienceYears,
      portfolioImages: entity.portfolioImages,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      isAvailable: entity.isAvailable,
    );
  }
}
