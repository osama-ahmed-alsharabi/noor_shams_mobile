import 'package:equatable/equatable.dart';

class ClientChatMessageModel extends Equatable {
  final String id;
  final String orderId;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  // Sender info (joined)
  final String? senderName;
  final String? senderAvatarUrl;

  const ClientChatMessageModel({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
  });

  factory ClientChatMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;

    return ClientChatMessageModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: sender?['name'] as String?,
      senderAvatarUrl: sender?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'sender_id': senderId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    senderId,
    message,
    isRead,
    createdAt,
    senderName,
    senderAvatarUrl,
  ];
}
