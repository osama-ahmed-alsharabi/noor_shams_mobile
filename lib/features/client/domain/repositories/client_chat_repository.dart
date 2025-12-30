import '../../data/models/client_chat_message_model.dart';

/// Repository interface for client chat
abstract class ClientChatRepository {
  /// Get chat messages for an order
  Future<List<ClientChatMessageModel>> getMessages(String orderId);

  /// Send a message
  Future<ClientChatMessageModel> sendMessage({
    required String orderId,
    required String message,
  });

  /// Subscribe to new messages (realtime)
  Stream<List<ClientChatMessageModel>> subscribeToMessages(String orderId);

  /// Mark messages as read
  Future<void> markMessagesAsRead(String orderId);
}
