import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/channel_repository_impl.dart';
import '../../data/services/image_upload_service.dart';
import '../../domain/repositories/channel_repository.dart';
import 'channel_state.dart';

class ChannelCubit extends Cubit<ChannelState> {
  final ChannelRepository _repository;
  final ImageUploadService _imageService;

  ChannelCubit({ChannelRepository? repository})
    : _repository = repository ?? ChannelRepositoryImpl(),
      _imageService = ImageUploadService(),
      super(ChannelInitial());

  Future<void> loadChannels() async {
    emit(ChannelLoading());
    try {
      final channels = await _repository.getMyChannels();
      emit(ChannelsLoaded(channels));
    } catch (e) {
      emit(ChannelError('فشل في تحميل القنوات: $e'));
    }
  }

  Future<void> createChannel({
    required String name,
    String? description,
    String? coverImageUrl,
  }) async {
    emit(ChannelLoading());
    try {
      final channel = await _repository.createChannel(
        name: name,
        description: description,
        coverImageUrl: coverImageUrl,
      );
      emit(ChannelOperationSuccess('تم إنشاء القناة بنجاح', channel: channel));
      await loadChannels();
    } catch (e) {
      emit(ChannelError('فشل في إنشاء القناة: $e'));
    }
  }

  Future<void> updateChannel({
    required String id,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isActive,
  }) async {
    emit(ChannelLoading());
    try {
      final channel = await _repository.updateChannel(
        id: id,
        name: name,
        description: description,
        coverImageUrl: coverImageUrl,
        isActive: isActive,
      );
      emit(ChannelOperationSuccess('تم تحديث القناة بنجاح', channel: channel));
      await loadChannels();
    } catch (e) {
      emit(ChannelError('فشل في تحديث القناة: $e'));
    }
  }

  Future<void> deleteChannel(String id) async {
    emit(ChannelLoading());
    try {
      await _repository.deleteChannel(id);
      emit(const ChannelOperationSuccess('تم حذف القناة بنجاح'));
      await loadChannels();
    } catch (e) {
      emit(ChannelError('فشل في حذف القناة: $e'));
    }
  }

  Future<void> toggleChannelStatus(String id, bool isActive) async {
    try {
      await _repository.toggleChannelStatus(id, isActive);
      await loadChannels();
    } catch (e) {
      emit(ChannelError('فشل في تغيير حالة القناة: $e'));
    }
  }

  /// Pick and upload channel cover image
  Future<String?> pickAndUploadCoverImage(String channelId) async {
    try {
      final image = await _imageService.pickImageFromGallery();
      if (image == null) return null;

      emit(ChannelLoading());
      final imageUrl = await _imageService.uploadChannelCover(image, channelId);
      return imageUrl;
    } catch (e) {
      emit(ChannelError('فشل في رفع صورة القناة: $e'));
      return null;
    }
  }

  /// Pick image without uploading (for create view)
  Future<XFile?> pickImage() async {
    return await _imageService.pickImageFromGallery();
  }

  /// Upload channel cover
  Future<String?> uploadCoverImage(XFile image, String channelId) async {
    try {
      return await _imageService.uploadChannelCover(image, channelId);
    } catch (e) {
      emit(ChannelError('فشل في رفع صورة القناة: $e'));
      return null;
    }
  }
}
