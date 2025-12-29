import '../entities/offer_entity.dart';

abstract class OfferRepository {
  Future<List<OfferEntity>> getOffersByChannel(String channelId);
  Future<List<OfferEntity>> getMyOffers();
  Future<OfferEntity?> getOfferById(String id);
  Future<OfferEntity> createOffer({
    required String channelId,
    required String title,
    String? description,
    required double price,
    int? durationDays,
    String? imageUrl,
  });
  Future<OfferEntity> updateOffer({
    required String id,
    String? title,
    String? description,
    double? price,
    int? durationDays,
    String? imageUrl,
    bool? isActive,
  });
  Future<void> deleteOffer(String id);
  Future<void> toggleOfferStatus(String id, bool isActive);
}
