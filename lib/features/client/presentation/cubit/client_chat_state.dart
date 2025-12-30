import 'package:equatable/equatable.dart';
import '../../data/models/client_chat_message_model.dart';

abstract class ClientChatState extends Equatable {
  const ClientChatState();

  @override
  List<Object?> get props => [];
}

class ClientChatInitial extends ClientChatState {}

class ClientChatLoading extends ClientChatState {}

class ClientChatLoaded extends ClientChatState {
  final List<ClientChatMessageModel> messages;
  final String orderId;

  const ClientChatLoaded({required this.messages, required this.orderId});

  @override
  List<Object?> get props => [messages, orderId];
}

class ClientChatMessageSent extends ClientChatState {
  final ClientChatMessageModel message;

  const ClientChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientChatError extends ClientChatState {
  final String message;

  const ClientChatError(this.message);

  @override
  List<Object?> get props => [message];
}
