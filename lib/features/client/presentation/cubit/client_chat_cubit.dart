import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/client_chat_message_model.dart';
import '../../data/repositories/client_chat_repository_impl.dart';
import '../../domain/repositories/client_chat_repository.dart';
import 'client_chat_state.dart';

class ClientChatCubit extends Cubit<ClientChatState> {
  final ClientChatRepository _repository;
  StreamSubscription<List<ClientChatMessageModel>>? _subscription;
  String? _currentOrderId;

  ClientChatCubit({ClientChatRepository? repository})
    : _repository = repository ?? ClientChatRepositoryImpl(),
      super(ClientChatInitial());

  Future<void> loadChat(String orderId) async {
    _currentOrderId = orderId;
    emit(ClientChatLoading());
    try {
      final messages = await _repository.getMessages(orderId);
      emit(ClientChatLoaded(messages: messages, orderId: orderId));

      // Mark messages as read
      await _repository.markMessagesAsRead(orderId);

      // Subscribe to realtime updates
      _subscribeToMessages(orderId);
    } catch (e) {
      emit(ClientChatError('فشل في تحميل المحادثة: $e'));
    }
  }

  void _subscribeToMessages(String orderId) {
    _subscription?.cancel();
    _subscription = _repository
        .subscribeToMessages(orderId)
        .listen(
          (messages) {
            emit(ClientChatLoaded(messages: messages, orderId: orderId));
            _repository.markMessagesAsRead(orderId);
          },
          onError: (e) {
            emit(ClientChatError('فشل في الاتصال المباشر: $e'));
          },
        );
  }

  Future<void> sendMessage(String message) async {
    if (_currentOrderId == null || message.trim().isEmpty) return;

    try {
      final sentMessage = await _repository.sendMessage(
        orderId: _currentOrderId!,
        message: message.trim(),
      );
      emit(ClientChatMessageSent(sentMessage));

      // Reload messages
      final messages = await _repository.getMessages(_currentOrderId!);
      emit(ClientChatLoaded(messages: messages, orderId: _currentOrderId!));
    } catch (e) {
      emit(ClientChatError('فشل في إرسال الرسالة: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    (_repository as ClientChatRepositoryImpl).dispose();
    return super.close();
  }
}
