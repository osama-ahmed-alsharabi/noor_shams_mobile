import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.orderId,
    required super.senderId,
    required super.message,
    required super.isRead,
    required super.createdAt,
    super.senderName,
    super.senderAvatarUrl,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Handle joined sender data
    String? senderName;
    String? senderAvatarUrl;
    if (json['sender'] != null && json['sender'] is Map) {
      senderName = json['sender']['name'] as String?;
      senderAvatarUrl = json['sender']['avatar_url'] as String?;
    }

    return ChatMessageModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'sender_id': senderId,
      'message': message,
      'is_read': isRead,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {'order_id': orderId, 'sender_id': senderId, 'message': message};
  }

  ChatMessageModel copyWith({
    String? id,
    String? orderId,
    String? senderId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? senderName,
    String? senderAvatarUrl,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
    );
  }
}
