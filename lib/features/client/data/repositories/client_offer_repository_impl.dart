import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_offer_model.dart';
import '../../domain/entities/client_offer_entity.dart';
import '../../domain/repositories/client_offer_repository.dart';

class ClientOfferRepositoryImpl implements ClientOfferRepository {
  final SupabaseClient _supabase;

  ClientOfferRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  static const String _selectQuery = '''
    *,
    channel:channels!channel_id(name, cover_image_url),
    provider:users!provider_id(name, avatar_url)
  ''';

  @override
  Future<List<ClientOfferEntity>> getActiveOffers() async {
    final response = await _supabase
        .from('offers')
        .select(_selectQuery)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ClientOfferModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ClientOfferEntity>> getOffersByChannel(String channelId) async {
    final response = await _supabase
        .from('offers')
        .select(_selectQuery)
        .eq('channel_id', channelId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ClientOfferModel.fromJson(json))
        .toList();
  }

  @override
  Future<ClientOfferEntity?> getOfferById(String id) async {
    final response = await _supabase
        .from('offers')
        .select(_selectQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ClientOfferModel.fromJson(response);
  }

  @override
  Future<List<ClientOfferEntity>> searchOffers(String query) async {
    final response = await _supabase
        .from('offers')
        .select(_selectQuery)
        .eq('is_active', true)
        .or('title.ilike.%$query%,description.ilike.%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ClientOfferModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ClientOfferEntity>> getFilteredOffers({
    double? minPrice,
    double? maxPrice,
    int? maxDurationDays,
    String? sortBy,
  }) async {
    // Build the query step by step and execute
    var baseQuery = _supabase
        .from('offers')
        .select(_selectQuery)
        .eq('is_active', true);

    // Apply filters
    if (minPrice != null) {
      baseQuery = baseQuery.gte('price', minPrice);
    }
    if (maxPrice != null) {
      baseQuery = baseQuery.lte('price', maxPrice);
    }
    if (maxDurationDays != null) {
      baseQuery = baseQuery.lte('duration_days', maxDurationDays);
    }

    // Apply sorting and execute
    List<dynamic> response;
    switch (sortBy) {
      case 'price_asc':
        response = await baseQuery.order('price', ascending: true);
        break;
      case 'price_desc':
        response = await baseQuery.order('price', ascending: false);
        break;
      case 'duration':
        response = await baseQuery.order('duration_days', ascending: true);
        break;
      case 'newest':
      default:
        response = await baseQuery.order('created_at', ascending: false);
    }

    return response.map((json) => ClientOfferModel.fromJson(json)).toList();
  }

  @override
  Future<List<ClientOfferEntity>> getFeaturedOffers({int limit = 5}) async {
    final response = await _supabase
        .from('offers')
        .select(_selectQuery)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => ClientOfferModel.fromJson(json))
        .toList();
  }
}
