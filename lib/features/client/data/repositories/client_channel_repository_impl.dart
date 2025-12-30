import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_channel_model.dart';
import '../../domain/entities/client_channel_entity.dart';
import '../../domain/repositories/client_channel_repository.dart';

class ClientChannelRepositoryImpl implements ClientChannelRepository {
  final SupabaseClient _supabase;

  ClientChannelRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<ClientChannelEntity>> getActiveChannels() async {
    final response = await _supabase
        .from('channels')
        .select('''
          *,
          provider:users!provider_id(name, avatar_url)
        ''')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ClientChannelModel.fromJson(json))
        .toList();
  }

  @override
  Future<ClientChannelEntity?> getChannelById(String id) async {
    final response = await _supabase
        .from('channels')
        .select('''
          *,
          provider:users!provider_id(name, avatar_url)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ClientChannelModel.fromJson(response);
  }

  @override
  Future<List<ClientChannelEntity>> searchChannels(String query) async {
    final response = await _supabase
        .from('channels')
        .select('''
          *,
          provider:users!provider_id(name, avatar_url)
        ''')
        .eq('is_active', true)
        .or('name.ilike.%$query%,description.ilike.%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ClientChannelModel.fromJson(json))
        .toList();
  }
}
