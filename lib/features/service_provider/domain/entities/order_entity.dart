import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.rejected:
        return 'مرفوض';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String? offerId;
  final String channelId;
  final String clientId;
  final String providerId;
  final OrderStatus status;
  final double? proposedPrice;
  final String? clientNotes;
  final String? providerNotes;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final String? clientName;
  final String? offerTitle;

  const OrderEntity({
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
    this.clientName,
    this.offerTitle,
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
  ];
}
