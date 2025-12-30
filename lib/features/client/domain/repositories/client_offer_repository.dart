import '../entities/client_offer_entity.dart';

/// Repository interface for browsing offers
abstract class ClientOfferRepository {
  /// Get all active offers
  Future<List<ClientOfferEntity>> getActiveOffers();

  /// Get offers by channel ID
  Future<List<ClientOfferEntity>> getOffersByChannel(String channelId);

  /// Get offer by ID
  Future<ClientOfferEntity?> getOfferById(String id);

  /// Search offers by title or description
  Future<List<ClientOfferEntity>> searchOffers(String query);

  /// Get offers filtered and sorted
  Future<List<ClientOfferEntity>> getFilteredOffers({
    double? minPrice,
    double? maxPrice,
    int? maxDurationDays,
    String? sortBy, // 'price_asc', 'price_desc', 'newest', 'duration'
  });

  /// Get featured/popular offers
  Future<List<ClientOfferEntity>> getFeaturedOffers({int limit = 5});
}
