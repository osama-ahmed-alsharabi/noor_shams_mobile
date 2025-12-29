import 'package:noor_shams_mobile/features/auth/domain/entities/user_entity.dart';

class ServiceProviderEntity extends UserEntity {
  final String profession;
  final String bio;
  final int experienceYears;
  final List<String> portfolioImages;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  const ServiceProviderEntity({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required this.profession,
    required this.bio,
    required this.experienceYears,
    required this.portfolioImages,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
  });

  @override
  List<Object> get props => [
    ...super.props,
    profession,
    bio,
    experienceYears,
    portfolioImages,
    rating,
    reviewCount,
    isAvailable,
  ];
}
