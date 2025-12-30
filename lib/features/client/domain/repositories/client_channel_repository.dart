import '../entities/client_channel_entity.dart';

/// Repository interface for browsing channels
abstract class ClientChannelRepository {
  /// Get all active channels with provider info
  Future<List<ClientChannelEntity>> getActiveChannels();

  /// Get channel by ID with provider info
  Future<ClientChannelEntity?> getChannelById(String id);

  /// Search channels by name
  Future<List<ClientChannelEntity>> searchChannels(String query);
}
