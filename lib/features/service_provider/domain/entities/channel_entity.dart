import 'package:equatable/equatable.dart';

class ChannelEntity extends Equatable {
  final String id;
  final String providerId;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChannelEntity({
    required this.id,
    required this.providerId,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
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
    updatedAt,
  ];
}
