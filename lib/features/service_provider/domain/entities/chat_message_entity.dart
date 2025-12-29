import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String orderId;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  // Optional joined data
  final String? senderName;
  final String? senderAvatarUrl;

  const ChatMessageEntity({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    senderId,
    message,
    isRead,
    createdAt,
  ];
}
