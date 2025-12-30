import '../entities/client_order_entity.dart';

/// Repository interface for client orders
abstract class ClientOrderRepository {
  /// Get all orders for current client
  Future<List<ClientOrderEntity>> getMyOrders();

  /// Get orders filtered by status
  Future<List<ClientOrderEntity>> getOrdersByStatus(String status);

  /// Get order by ID
  Future<ClientOrderEntity?> getOrderById(String id);

  /// Place order from existing offer
  Future<ClientOrderEntity> placeOrder({
    required String offerId,
    required String channelId,
    required String providerId,
    String? clientNotes,
    double? proposedPrice,
  });

  /// Place custom order (no existing offer)
  Future<ClientOrderEntity> placeCustomOrder({
    required String channelId,
    required String providerId,
    required String clientNotes,
    double? proposedPrice,
  });

  /// Cancel pending order
  Future<void> cancelOrder(String orderId);

  /// Get order statistics for client
  Future<Map<String, int>> getOrderStats();
}
