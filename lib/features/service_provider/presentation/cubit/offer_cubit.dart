import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/offer_repository_impl.dart';
import '../../domain/repositories/offer_repository.dart';
import 'offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _repository;
  String? _currentChannelId;

  OfferCubit({OfferRepository? repository})
    : _repository = repository ?? OfferRepositoryImpl(),
      super(OfferInitial());

  Future<void> loadOffers({String? channelId}) async {
    emit(OfferLoading());
    try {
      _currentChannelId = channelId;
      final offers = channelId != null
          ? await _repository.getOffersByChannel(channelId)
          : await _repository.getMyOffers();
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OfferError('فشل في تحميل العروض: $e'));
    }
  }

  Future<void> createOffer({
    required String channelId,
    required String title,
    String? description,
    required double price,
    int? durationDays,
    String? imageUrl,
  }) async {
    emit(OfferLoading());
    try {
      final offer = await _repository.createOffer(
        channelId: channelId,
        title: title,
        description: description,
        price: price,
        durationDays: durationDays,
        imageUrl: imageUrl,
      );
      emit(OfferOperationSuccess('تم إضافة العرض بنجاح', offer: offer));
      await loadOffers(channelId: _currentChannelId);
    } catch (e) {
      emit(OfferError('فشل في إضافة العرض: $e'));
    }
  }

  Future<void> updateOffer({
    required String id,
    String? title,
    String? description,
    double? price,
    int? durationDays,
    String? imageUrl,
    bool? isActive,
  }) async {
    emit(OfferLoading());
    try {
      final offer = await _repository.updateOffer(
        id: id,
        title: title,
        description: description,
        price: price,
        durationDays: durationDays,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      emit(OfferOperationSuccess('تم تحديث العرض بنجاح', offer: offer));
      await loadOffers(channelId: _currentChannelId);
    } catch (e) {
      emit(OfferError('فشل في تحديث العرض: $e'));
    }
  }

  Future<void> deleteOffer(String id) async {
    emit(OfferLoading());
    try {
      await _repository.deleteOffer(id);
      emit(const OfferOperationSuccess('تم حذف العرض بنجاح'));
      await loadOffers(channelId: _currentChannelId);
    } catch (e) {
      emit(OfferError('فشل في حذف العرض: $e'));
    }
  }

  Future<void> toggleOfferStatus(String id, bool isActive) async {
    try {
      await _repository.toggleOfferStatus(id, isActive);
      await loadOffers(channelId: _currentChannelId);
    } catch (e) {
      emit(OfferError('فشل في تغيير حالة العرض: $e'));
    }
  }
}
