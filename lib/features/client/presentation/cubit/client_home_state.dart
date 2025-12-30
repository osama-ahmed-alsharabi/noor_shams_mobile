import 'package:equatable/equatable.dart';
import '../../domain/entities/client_channel_entity.dart';
import '../../domain/entities/client_offer_entity.dart';

abstract class ClientHomeState extends Equatable {
  const ClientHomeState();

  @override
  List<Object?> get props => [];
}

class ClientHomeInitial extends ClientHomeState {}

class ClientHomeLoading extends ClientHomeState {}

class ClientHomeLoaded extends ClientHomeState {
  final List<ClientChannelEntity> featuredChannels;
  final List<ClientOfferEntity> featuredOffers;
  final Map<String, int> orderStats;

  const ClientHomeLoaded({
    required this.featuredChannels,
    required this.featuredOffers,
    required this.orderStats,
  });

  @override
  List<Object?> get props => [featuredChannels, featuredOffers, orderStats];
}

class ClientHomeError extends ClientHomeState {
  final String message;

  const ClientHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
