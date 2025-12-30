import 'package:equatable/equatable.dart';
import '../../domain/entities/client_channel_entity.dart';

abstract class BrowseChannelsState extends Equatable {
  const BrowseChannelsState();

  @override
  List<Object?> get props => [];
}

class BrowseChannelsInitial extends BrowseChannelsState {}

class BrowseChannelsLoading extends BrowseChannelsState {}

class BrowseChannelsLoaded extends BrowseChannelsState {
  final List<ClientChannelEntity> channels;
  final String? searchQuery;

  const BrowseChannelsLoaded({required this.channels, this.searchQuery});

  @override
  List<Object?> get props => [channels, searchQuery];
}

class BrowseChannelsError extends BrowseChannelsState {
  final String message;

  const BrowseChannelsError(this.message);

  @override
  List<Object?> get props => [message];
}
