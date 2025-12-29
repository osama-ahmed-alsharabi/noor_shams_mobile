import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/channel_entity.dart';
import '../../domain/repositories/channel_repository.dart';
import '../models/channel_model.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final SupabaseClient _supabase;

  ChannelRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  @override
  Future<List<ChannelEntity>> getMyChannels() async {
    final response = await _supabase
        .from('channels')
        .select()
        .eq('provider_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ChannelModel.fromJson(json))
        .toList();
  }

  @override
  Future<ChannelEntity?> getChannelById(String id) async {
    final response = await _supabase
        .from('channels')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ChannelModel.fromJson(response);
  }

  @override
  Future<ChannelEntity> createChannel({
    required String name,
    String? description,
    String? coverImageUrl,
  }) async {
    final model = ChannelModel(
      id: '',
      providerId: _userId,
      name: name,
      description: description,
      coverImageUrl: coverImageUrl,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _supabase
        .from('channels')
        .insert(model.toInsertJson())
        .select()
        .single();

    return ChannelModel.fromJson(response);
  }

  @override
  Future<ChannelEntity> updateChannel({
    required String id,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isActive,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (coverImageUrl != null) updateData['cover_image_url'] = coverImageUrl;
    if (isActive != null) updateData['is_active'] = isActive;

    final response = await _supabase
        .from('channels')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return ChannelModel.fromJson(response);
  }

  @override
  Future<void> deleteChannel(String id) async {
    await _supabase.from('channels').delete().eq('id', id);
  }

  @override
  Future<void> toggleChannelStatus(String id, bool isActive) async {
    await _supabase
        .from('channels')
        .update({'is_active': isActive})
        .eq('id', id);
  }
}
