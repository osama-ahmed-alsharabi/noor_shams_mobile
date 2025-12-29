import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getProviderOrders({OrderStatus? status});
  Future<List<OrderEntity>> getClientOrders({OrderStatus? status});
  Future<OrderEntity?> getOrderById(String id);
  Future<OrderEntity> createOrder({
    String? offerId,
    required String channelId,
    required String providerId,
    double? proposedPrice,
    String? clientNotes,
    bool isCustom = false,
  });
  Future<void> updateOrderStatus(String id, OrderStatus status);
  Future<void> addProviderNotes(String id, String notes);
  Future<int> getActiveOrdersCount();
  Future<double> getTotalRevenue();
}
