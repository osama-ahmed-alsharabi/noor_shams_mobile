import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
  final String id;
  final String channelId;
  final String providerId;
  final String title;
  final String? description;
  final double price;
  final int? durationDays;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OfferEntity({
    required this.id,
    required this.channelId,
    required this.providerId,
    required this.title,
    this.description,
    required this.price,
    this.durationDays,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    channelId,
    providerId,
    title,
    description,
    price,
    durationDays,
    imageUrl,
    isActive,
    createdAt,
    updatedAt,
  ];
}
