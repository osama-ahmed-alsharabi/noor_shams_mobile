import 'package:equatable/equatable.dart';
import '../../domain/entities/client_offer_entity.dart';

abstract class BrowseOffersState extends Equatable {
  const BrowseOffersState();

  @override
  List<Object?> get props => [];
}

class BrowseOffersInitial extends BrowseOffersState {}

class BrowseOffersLoading extends BrowseOffersState {}

class BrowseOffersLoaded extends BrowseOffersState {
  final List<ClientOfferEntity> offers;
  final String? searchQuery;
  final String? sortBy;
  final double? minPrice;
  final double? maxPrice;

  const BrowseOffersLoaded({
    required this.offers,
    this.searchQuery,
    this.sortBy,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [offers, searchQuery, sortBy, minPrice, maxPrice];
}

class BrowseOffersError extends BrowseOffersState {
  final String message;

  const BrowseOffersError(this.message);

  @override
  List<Object?> get props => [message];
}
