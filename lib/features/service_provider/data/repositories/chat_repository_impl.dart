import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  final _messageController = StreamController<ChatMessageEntity>.broadcast();

  ChatRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  @override
  Future<List<ChatMessageEntity>> getMessages(String orderId) async {
    final response = await _supabase
        .from('chat_messages')
        .select('*, sender:users!sender_id(name, avatar_url)')
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ChatMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<ChatMessageEntity> sendMessage({
    required String orderId,
    required String message,
  }) async {
    final model = ChatMessageModel(
      id: '',
      orderId: orderId,
      senderId: _userId,
      message: message,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final response = await _supabase
        .from('chat_messages')
        .insert(model.toInsertJson())
        .select('*, sender:users!sender_id(name, avatar_url)')
        .single();

    return ChatMessageModel.fromJson(response);
  }

  @override
  Future<void> markAsRead(String orderId) async {
    await _supabase
        .from('chat_messages')
        .update({'is_read': true})
        .eq('order_id', orderId)
        .neq('sender_id', _userId);
  }

  @override
  Stream<ChatMessageEntity> subscribeToMessages(String orderId) {
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
            try {
              // Fetch the complete message with sender info
              final response = await _supabase
                  .from('chat_messages')
                  .select('*, sender:users!sender_id(name, avatar_url)')
                  .eq('id', payload.newRecord['id'])
                  .single();

              final message = ChatMessageModel.fromJson(response);
              _messageController.add(message);
            } catch (e) {
              // debugPrint('Stacktrace: $e');
            }
          },
        )
        .subscribe((status, error) {
          if (error != null) {
            // debugPrint('Realtime error: $error');
          }
        });

    return _messageController.stream;
  }

  @override
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
