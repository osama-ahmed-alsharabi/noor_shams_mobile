import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit({OrderRepository? repository})
    : _repository = repository ?? OrderRepositoryImpl(),
      super(OrderInitial());

  Future<void> loadProviderOrders({OrderStatus? status}) async {
    emit(OrderLoading());
    try {
      final results = await Future.wait([
        _repository.getProviderOrders(status: status),
        _repository.getActiveOrdersCount(),
        _repository.getTotalRevenue(),
      ]);

      emit(
        OrdersLoaded(
          orders: results[0] as List<OrderEntity>,
          activeCount: results[1] as int,
          totalRevenue: results[2] as double,
        ),
      );
    } catch (e) {
      emit(OrderError('فشل في تحميل الطلبات: $e'));
    }
  }

  Future<void> loadOrderDetails(String orderId) async {
    emit(OrderLoading());
    try {
      final order = await _repository.getOrderById(orderId);
      if (order != null) {
        emit(OrderDetailsLoaded(order));
      } else {
        emit(const OrderError('الطلب غير موجود'));
      }
    } catch (e) {
      emit(OrderError('فشل في تحميل تفاصيل الطلب: $e'));
    }
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      await _repository.updateOrderStatus(orderId, OrderStatus.accepted);
      emit(const OrderOperationSuccess('تم قبول الطلب بنجاح'));
      await loadProviderOrders();
    } catch (e) {
      emit(OrderError('فشل في قبول الطلب: $e'));
    }
  }

  Future<void> rejectOrder(String orderId) async {
    try {
      await _repository.updateOrderStatus(orderId, OrderStatus.rejected);
      emit(const OrderOperationSuccess('تم رفض الطلب'));
      await loadProviderOrders();
    } catch (e) {
      emit(OrderError('فشل في رفض الطلب: $e'));
    }
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await _repository.updateOrderStatus(orderId, OrderStatus.completed);
      emit(const OrderOperationSuccess('تم إكمال الطلب بنجاح'));
      await loadProviderOrders();
    } catch (e) {
      emit(OrderError('فشل في إكمال الطلب: $e'));
    }
  }

  Future<void> addNotes(String orderId, String notes) async {
    try {
      await _repository.addProviderNotes(orderId, notes);
      emit(const OrderOperationSuccess('تم إضافة الملاحظات'));
    } catch (e) {
      emit(OrderError('فشل في إضافة الملاحظات: $e'));
    }
  }
}
