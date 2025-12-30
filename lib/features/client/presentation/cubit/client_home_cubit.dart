import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/client_channel_repository_impl.dart';
import '../../data/repositories/client_offer_repository_impl.dart';
import '../../data/repositories/client_order_repository_impl.dart';
import '../../domain/entities/client_channel_entity.dart';
import '../../domain/entities/client_offer_entity.dart';
import '../../domain/repositories/client_channel_repository.dart';
import '../../domain/repositories/client_offer_repository.dart';
import '../../domain/repositories/client_order_repository.dart';
import 'client_home_state.dart';

class ClientHomeCubit extends Cubit<ClientHomeState> {
  final ClientChannelRepository _channelRepo;
  final ClientOfferRepository _offerRepo;
  final ClientOrderRepository _orderRepo;

  ClientHomeCubit({
    ClientChannelRepository? channelRepo,
    ClientOfferRepository? offerRepo,
    ClientOrderRepository? orderRepo,
  }) : _channelRepo = channelRepo ?? ClientChannelRepositoryImpl(),
       _offerRepo = offerRepo ?? ClientOfferRepositoryImpl(),
       _orderRepo = orderRepo ?? ClientOrderRepositoryImpl(),
       super(ClientHomeInitial());

  Future<void> loadHomeData() async {
    emit(ClientHomeLoading());
    try {
      final results = await Future.wait([
        _channelRepo.getActiveChannels(),
        _offerRepo.getFeaturedOffers(limit: 6),
        _orderRepo.getOrderStats(),
      ]);

      emit(
        ClientHomeLoaded(
          featuredChannels: results[0] as List<ClientChannelEntity>,
          featuredOffers: results[1] as List<ClientOfferEntity>,
          orderStats: results[2] as Map<String, int>,
        ),
      );
    } catch (e) {
      emit(ClientHomeError('فشل في تحميل البيانات: $e'));
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}
