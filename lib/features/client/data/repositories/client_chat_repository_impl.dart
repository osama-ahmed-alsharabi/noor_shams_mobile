import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_chat_message_model.dart';
import '../../domain/repositories/client_chat_repository.dart';

class ClientChatRepositoryImpl implements ClientChatRepository {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ClientChatRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser?.id ?? '';

  static const String _selectQuery = '''
    *,
    sender:users!sender_id(name, avatar_url)
  ''';

  @override
  Future<List<ClientChatMessageModel>> getMessages(String orderId) async {
    final response = await _supabase
        .from('chat_messages')
        .select(_selectQuery)
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ClientChatMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<ClientChatMessageModel> sendMessage({
    required String orderId,
    required String message,
  }) async {
    final response = await _supabase
        .from('chat_messages')
        .insert({'order_id': orderId, 'sender_id': _userId, 'message': message})
        .select(_selectQuery)
        .single();

    return ClientChatMessageModel.fromJson(response);
  }

  @override
  Stream<List<ClientChatMessageModel>> subscribeToMessages(String orderId) {
    final controller = StreamController<List<ClientChatMessageModel>>();

    _channel?.unsubscribe();
    _channel = _supabase
        .channel('chat:$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'order_id',
            value: orderId,
          ),
          callback: (payload) async {
            // Fetch all messages when new one arrives
            final messages = await getMessages(orderId);
            controller.add(messages);
          },
        )
        .subscribe();

    // Initial load
    getMessages(orderId).then((messages) {
      controller.add(messages);
    });

    return controller.stream;
  }

  @override
  Future<void> markMessagesAsRead(String orderId) async {
    await _supabase
        .from('chat_messages')
        .update({'is_read': true})
        .eq('order_id', orderId)
        .neq('sender_id', _userId)
        .eq('is_read', false);
  }

  void dispose() {
    _channel?.unsubscribe();
  }
}
