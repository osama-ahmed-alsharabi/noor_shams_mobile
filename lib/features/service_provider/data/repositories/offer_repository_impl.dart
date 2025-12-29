import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offer_repository.dart';
import '../models/offer_model.dart';

class OfferRepositoryImpl implements OfferRepository {
  final SupabaseClient _supabase;

  OfferRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  @override
  Future<List<OfferEntity>> getOffersByChannel(String channelId) async {
    final response = await _supabase
        .from('offers')
        .select()
        .eq('channel_id', channelId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => OfferModel.fromJson(json)).toList();
  }

  @override
  Future<List<OfferEntity>> getMyOffers() async {
    final response = await _supabase
        .from('offers')
        .select()
        .eq('provider_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => OfferModel.fromJson(json)).toList();
  }

  @override
  Future<OfferEntity?> getOfferById(String id) async {
    final response = await _supabase
        .from('offers')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return OfferModel.fromJson(response);
  }

  @override
  Future<OfferEntity> createOffer({
    required String channelId,
    required String title,
    String? description,
    required double price,
    int? durationDays,
    String? imageUrl,
  }) async {
    final model = OfferModel(
      id: '',
      channelId: channelId,
      providerId: _userId,
      title: title,
      description: description,
      price: price,
      durationDays: durationDays,
      imageUrl: imageUrl,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _supabase
        .from('offers')
        .insert(model.toInsertJson())
        .select()
        .single();

    return OfferModel.fromJson(response);
  }

  @override
  Future<OfferEntity> updateOffer({
    required String id,
    String? title,
    String? description,
    double? price,
    int? durationDays,
    String? imageUrl,
    bool? isActive,
  }) async {
    final updateData = <String, dynamic>{};
    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (price != null) updateData['price'] = price;
    if (durationDays != null) updateData['duration_days'] = durationDays;
    if (imageUrl != null) updateData['image_url'] = imageUrl;
    if (isActive != null) updateData['is_active'] = isActive;

    final response = await _supabase
        .from('offers')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return OfferModel.fromJson(response);
  }

  @override
  Future<void> deleteOffer(String id) async {
    await _supabase.from('offers').delete().eq('id', id);
  }

  @override
  Future<void> toggleOfferStatus(String id, bool isActive) async {
    await _supabase.from('offers').update({'is_active': isActive}).eq('id', id);
  }
}
