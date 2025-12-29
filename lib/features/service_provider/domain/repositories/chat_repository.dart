import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages(String orderId);
  Future<ChatMessageEntity> sendMessage({
    required String orderId,
    required String message,
  });
  Future<void> markAsRead(String orderId);
  Stream<ChatMessageEntity> subscribeToMessages(String orderId);
  void unsubscribe();
}
