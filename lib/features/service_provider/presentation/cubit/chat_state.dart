import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageEntity> messages;
  final String orderId;

  const ChatLoaded({required this.messages, required this.orderId});

  ChatLoaded copyWith({List<ChatMessageEntity>? messages}) {
    return ChatLoaded(messages: messages ?? this.messages, orderId: orderId);
  }

  @override
  List<Object?> get props => [messages, orderId];
}

class ChatMessageSent extends ChatState {
  final ChatMessageEntity message;

  const ChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
