import '../entities/channel_entity.dart';

abstract class ChannelRepository {
  Future<List<ChannelEntity>> getMyChannels();
  Future<ChannelEntity?> getChannelById(String id);
  Future<ChannelEntity> createChannel({
    required String name,
    String? description,
    String? coverImageUrl,
  });
  Future<ChannelEntity> updateChannel({
    required String id,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isActive,
  });
  Future<void> deleteChannel(String id);
  Future<void> toggleChannelStatus(String id, bool isActive);
}
