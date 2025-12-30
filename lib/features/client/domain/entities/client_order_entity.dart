import 'package:equatable/equatable.dart';

/// Order status enum
enum ClientOrderStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled;

  String get arabicName {
    switch (this) {
      case ClientOrderStatus.pending:
        return 'قيد الانتظار';
      case ClientOrderStatus.accepted:
        return 'مقبول';
      case ClientOrderStatus.rejected:
        return 'مرفوض';
      case ClientOrderStatus.completed:
        return 'مكتمل';
      case ClientOrderStatus.cancelled:
        return 'ملغي';
    }
  }

  static ClientOrderStatus fromString(String status) {
    return ClientOrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ClientOrderStatus.pending,
    );
  }
}

/// Order entity for client tracking
class ClientOrderEntity extends Equatable {
  final String id;
  final String? offerId;
  final String channelId;
  final String clientId;
  final String providerId;
  final ClientOrderStatus status;
  final double? proposedPrice;
  final String? clientNotes;
  final String? providerNotes;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final String? offerTitle;
  final double? offerPrice;
  final String? channelName;
  final String? providerName;
  final String? providerAvatarUrl;

  const ClientOrderEntity({
    required this.id,
    this.offerId,
    required this.channelId,
    required this.clientId,
    required this.providerId,
    required this.status,
    this.proposedPrice,
    this.clientNotes,
    this.providerNotes,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
    this.offerTitle,
    this.offerPrice,
    this.channelName,
    this.providerName,
    this.providerAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    offerId,
    channelId,
    clientId,
    providerId,
    status,
    proposedPrice,
    clientNotes,
    providerNotes,
    isCustom,
    createdAt,
    updatedAt,
    offerTitle,
    offerPrice,
    channelName,
    providerName,
    providerAvatarUrl,
  ];
}
