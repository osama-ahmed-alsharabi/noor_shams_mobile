import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/client_offer_repository_impl.dart';
import '../../domain/repositories/client_offer_repository.dart';
import 'browse_offers_state.dart';

class BrowseOffersCubit extends Cubit<BrowseOffersState> {
  final ClientOfferRepository _repository;
  String? _currentChannelId;

  BrowseOffersCubit({ClientOfferRepository? repository})
    : _repository = repository ?? ClientOfferRepositoryImpl(),
      super(BrowseOffersInitial());

  Future<void> loadOffers({String? channelId}) async {
    _currentChannelId = channelId;
    emit(BrowseOffersLoading());
    try {
      final offers = channelId != null
          ? await _repository.getOffersByChannel(channelId)
          : await _repository.getActiveOffers();
      emit(BrowseOffersLoaded(offers: offers));
    } catch (e) {
      emit(BrowseOffersError('فشل في تحميل العروض: $e'));
    }
  }

  Future<void> searchOffers(String query) async {
    if (query.isEmpty) {
      await loadOffers(channelId: _currentChannelId);
      return;
    }

    emit(BrowseOffersLoading());
    try {
      final offers = await _repository.searchOffers(query);
      emit(BrowseOffersLoaded(offers: offers, searchQuery: query));
    } catch (e) {
      emit(BrowseOffersError('فشل في البحث: $e'));
    }
  }

  Future<void> applyFilters({
    double? minPrice,
    double? maxPrice,
    int? maxDurationDays,
    String? sortBy,
  }) async {
    emit(BrowseOffersLoading());
    try {
      final offers = await _repository.getFilteredOffers(
        minPrice: minPrice,
        maxPrice: maxPrice,
        maxDurationDays: maxDurationDays,
        sortBy: sortBy,
      );
      emit(
        BrowseOffersLoaded(
          offers: offers,
          sortBy: sortBy,
          minPrice: minPrice,
          maxPrice: maxPrice,
        ),
      );
    } catch (e) {
      emit(BrowseOffersError('فشل في تطبيق الفلتر: $e'));
    }
  }

  Future<void> sortOffers(String sortBy) async {
    final currentState = state;
    if (currentState is BrowseOffersLoaded) {
      await applyFilters(
        minPrice: currentState.minPrice,
        maxPrice: currentState.maxPrice,
        sortBy: sortBy,
      );
    }
  }
}
