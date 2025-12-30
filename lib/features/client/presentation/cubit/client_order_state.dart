import 'package:equatable/equatable.dart';
import '../../domain/entities/client_order_entity.dart';

abstract class ClientOrderState extends Equatable {
  const ClientOrderState();

  @override
  List<Object?> get props => [];
}

class ClientOrderInitial extends ClientOrderState {}

class ClientOrderLoading extends ClientOrderState {}

class ClientOrdersLoaded extends ClientOrderState {
  final List<ClientOrderEntity> orders;
  final Map<String, int> stats;

  const ClientOrdersLoaded({required this.orders, required this.stats});

  @override
  List<Object?> get props => [orders, stats];
}

class ClientOrderPlaced extends ClientOrderState {
  final ClientOrderEntity order;
  final String message;

  const ClientOrderPlaced({required this.order, required this.message});

  @override
  List<Object?> get props => [order, message];
}

class ClientOrderCancelled extends ClientOrderState {
  final String message;

  const ClientOrderCancelled(this.message);

  @override
  List<Object?> get props => [message];
}

class ClientOrderError extends ClientOrderState {
  final String message;

  const ClientOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
