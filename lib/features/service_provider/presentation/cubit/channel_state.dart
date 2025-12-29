import 'package:equatable/equatable.dart';
import '../../domain/entities/channel_entity.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();

  @override
  List<Object?> get props => [];
}

class ChannelInitial extends ChannelState {}

class ChannelLoading extends ChannelState {}

class ChannelsLoaded extends ChannelState {
  final List<ChannelEntity> channels;

  const ChannelsLoaded(this.channels);

  @override
  List<Object?> get props => [channels];
}

class ChannelOperationSuccess extends ChannelState {
  final String message;
  final ChannelEntity? channel;

  const ChannelOperationSuccess(this.message, {this.channel});

  @override
  List<Object?> get props => [message, channel];
}

class ChannelError extends ChannelState {
  final String message;

  const ChannelError(this.message);

  @override
  List<Object?> get props => [message];
}
