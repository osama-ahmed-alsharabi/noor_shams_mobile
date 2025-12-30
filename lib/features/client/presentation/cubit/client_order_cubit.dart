import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/client_order_repository_impl.dart';
import '../../domain/entities/client_order_entity.dart';
import '../../domain/repositories/client_order_repository.dart';
import 'client_order_state.dart';

class ClientOrderCubit extends Cubit<ClientOrderState> {
  final ClientOrderRepository _repository;

  ClientOrderCubit({ClientOrderRepository? repository})
    : _repository = repository ?? ClientOrderRepositoryImpl(),
      super(ClientOrderInitial());

  Future<void> loadOrders() async {
    emit(ClientOrderLoading());
    try {
      final results = await Future.wait([
        _repository.getMyOrders(),
        _repository.getOrderStats(),
      ]);

      emit(
        ClientOrdersLoaded(
          orders: results[0] as List<ClientOrderEntity>,
          stats: results[1] as Map<String, int>,
        ),
      );
    } catch (e) {
      emit(ClientOrderError('فشل في تحميل الطلبات: $e'));
    }
  }

  Future<void> placeOrder({
    required String offerId,
    required String channelId,
    required String providerId,
    String? clientNotes,
    double? proposedPrice,
  }) async {
    emit(ClientOrderLoading());
    try {
      final order = await _repository.placeOrder(
        offerId: offerId,
        channelId: channelId,
        providerId: providerId,
        clientNotes: clientNotes,
        proposedPrice: proposedPrice,
      );
      emit(ClientOrderPlaced(order: order, message: 'تم إرسال طلبك بنجاح!'));
    } catch (e) {
      emit(ClientOrderError('فشل في إرسال الطلب: $e'));
    }
  }

  Future<void> placeCustomOrder({
    required String channelId,
    required String providerId,
    required String clientNotes,
    double? proposedPrice,
  }) async {
    emit(ClientOrderLoading());
    try {
      final order = await _repository.placeCustomOrder(
        channelId: channelId,
        providerId: providerId,
        clientNotes: clientNotes,
        proposedPrice: proposedPrice,
      );
      emit(
        ClientOrderPlaced(order: order, message: 'تم إرسال طلبك الخاص بنجاح!'),
      );
    } catch (e) {
      emit(ClientOrderError('فشل في إرسال الطلب: $e'));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _repository.cancelOrder(orderId);
      emit(const ClientOrderCancelled('تم إلغاء الطلب بنجاح'));
      await loadOrders();
    } catch (e) {
      emit(ClientOrderError('فشل في إلغاء الطلب: $e'));
    }
  }
}
