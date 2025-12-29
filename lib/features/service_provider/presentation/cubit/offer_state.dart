import 'package:equatable/equatable.dart';
import '../../domain/entities/offer_entity.dart';

abstract class OfferState extends Equatable {
  const OfferState();

  @override
  List<Object?> get props => [];
}

class OfferInitial extends OfferState {}

class OfferLoading extends OfferState {}

class OffersLoaded extends OfferState {
  final List<OfferEntity> offers;

  const OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

class OfferOperationSuccess extends OfferState {
  final String message;
  final OfferEntity? offer;

  const OfferOperationSuccess(this.message, {this.offer});

  @override
  List<Object?> get props => [message, offer];
}

class OfferError extends OfferState {
  final String message;

  const OfferError(this.message);

  @override
  List<Object?> get props => [message];
}
