import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/client_channel_repository_impl.dart';
import '../../domain/repositories/client_channel_repository.dart';
import 'browse_channels_state.dart';

class BrowseChannelsCubit extends Cubit<BrowseChannelsState> {
  final ClientChannelRepository _repository;

  BrowseChannelsCubit({ClientChannelRepository? repository})
    : _repository = repository ?? ClientChannelRepositoryImpl(),
      super(BrowseChannelsInitial());

  Future<void> loadChannels() async {
    emit(BrowseChannelsLoading());
    try {
      final channels = await _repository.getActiveChannels();
      emit(BrowseChannelsLoaded(channels: channels));
    } catch (e) {
      emit(BrowseChannelsError('فشل في تحميل القنوات: $e'));
    }
  }

  Future<void> searchChannels(String query) async {
    if (query.isEmpty) {
      await loadChannels();
      return;
    }

    emit(BrowseChannelsLoading());
    try {
      final channels = await _repository.searchChannels(query);
      emit(BrowseChannelsLoaded(channels: channels, searchQuery: query));
    } catch (e) {
      emit(BrowseChannelsError('فشل في البحث: $e'));
    }
  }
}
