import 'package:equatable/equatable.dart';

/// Channel entity for client browsing
class ClientChannelEntity extends Equatable {
  final String id;
  final String providerId;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final bool isActive;
  final DateTime createdAt;

  // Provider info (joined from users table)
  final String? providerName;
  final String? providerAvatarUrl;

  const ClientChannelEntity({
    required this.id,
    required this.providerId,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.isActive,
    required this.createdAt,
    this.providerName,
    this.providerAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    providerId,
    name,
    description,
    coverImageUrl,
    isActive,
    createdAt,
    providerName,
    providerAvatarUrl,
  ];
}
