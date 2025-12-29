import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription<ChatMessageEntity>? _subscription;
  List<ChatMessageEntity> _messages = [];
  String? _currentOrderId;

  ChatCubit({ChatRepository? repository})
    : _repository = repository ?? ChatRepositoryImpl(),
      super(ChatInitial());

  Future<void> loadMessages(String orderId) async {
    emit(ChatLoading());
    try {
      _currentOrderId = orderId;
      _messages = await _repository.getMessages(orderId);
      emit(ChatLoaded(messages: _messages, orderId: orderId));

      // Mark messages as read
      await _repository.markAsRead(orderId);

      // Subscribe to new messages
      _subscribeToMessages(orderId);
    } catch (e) {
      emit(ChatError('فشل في تحميل الرسائل: $e'));
    }
  }

  void _subscribeToMessages(String orderId) {
    _subscription?.cancel();
    _subscription = _repository
        .subscribeToMessages(orderId)
        .listen(
          (message) {
            _messages = [..._messages, message];
            emit(ChatLoaded(messages: _messages, orderId: orderId));
          },
          onError: (e) {
            // Handle subscription errors silently
          },
        );
  }

  Future<void> sendMessage(String message) async {
    if (_currentOrderId == null) return;

    try {
      final sentMessage = await _repository.sendMessage(
        orderId: _currentOrderId!,
        message: message,
      );
      // Message will be added via the subscription
      emit(ChatMessageSent(sentMessage));
    } catch (e) {
      emit(ChatError('فشل في إرسال الرسالة: $e'));
      // Restore previous state
      if (_currentOrderId != null) {
        emit(ChatLoaded(messages: _messages, orderId: _currentOrderId!));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _repository.unsubscribe();
    return super.close();
  }
}
