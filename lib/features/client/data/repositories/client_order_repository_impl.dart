import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_order_model.dart';
import '../../domain/entities/client_order_entity.dart';
import '../../domain/repositories/client_order_repository.dart';

class ClientOrderRepositoryImpl implements ClientOrderRepository {
  final SupabaseClient _supabase;

  ClientOrderRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  String get _clientId => _supabase.auth.currentUser?.id ?? '';

  static const String _selectQuery = '''
    *,
    offer:offers!offer_id(title, price),
    channel:channels!channel_id(name),
    provider:users!provider_id(name, avatar_url)
  ''';

  @override
  Future<List<ClientOrderEntity>> getMyOrders() async {
    final response = await _supabase
        .from('orders')
        .select(_selectQuery)
        .eq('client_id', _clientId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ClientOrderModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ClientOrderEntity>> getOrdersByStatus(String status) async {
    final response = await _supabase
        .from('orders')
        .select(_selectQuery)
        .eq('client_id', _clientId)
        .eq('status', status)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ClientOrderModel.fromJson(json))
        .toList();
  }

  @override
  Future<ClientOrderEntity?> getOrderById(String id) async {
    final response = await _supabase
        .from('orders')
        .select(_selectQuery)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ClientOrderModel.fromJson(response);
  }

  @override
  Future<ClientOrderEntity> placeOrder({
    required String offerId,
    required String channelId,
    required String providerId,
    String? clientNotes,
    double? proposedPrice,
  }) async {
    final data = ClientOrderModel.createOrderData(
      offerId: offerId,
      channelId: channelId,
      clientId: _clientId,
      providerId: providerId,
      clientNotes: clientNotes,
      proposedPrice: proposedPrice,
    );

    final response = await _supabase
        .from('orders')
        .insert(data)
        .select(_selectQuery)
        .single();

    return ClientOrderModel.fromJson(response);
  }

  @override
  Future<ClientOrderEntity> placeCustomOrder({
    required String channelId,
    required String providerId,
    required String clientNotes,
    double? proposedPrice,
  }) async {
    final data = ClientOrderModel.createCustomOrderData(
      channelId: channelId,
      clientId: _clientId,
      providerId: providerId,
      clientNotes: clientNotes,
      proposedPrice: proposedPrice,
    );

    final response = await _supabase
        .from('orders')
        .insert(data)
        .select(_selectQuery)
        .single();

    return ClientOrderModel.fromJson(response);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _supabase
        .from('orders')
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .eq('client_id', _clientId)
        .eq('status', 'pending');
  }

  @override
  Future<Map<String, int>> getOrderStats() async {
    final orders = await getMyOrders();

    return {
      'total': orders.length,
      'pending': orders
          .where((o) => o.status == ClientOrderStatus.pending)
          .length,
      'accepted': orders
          .where((o) => o.status == ClientOrderStatus.accepted)
          .length,
      'completed': orders
          .where((o) => o.status == ClientOrderStatus.completed)
          .length,
      'rejected': orders
          .where((o) => o.status == ClientOrderStatus.rejected)
          .length,
      'cancelled': orders
          .where((o) => o.status == ClientOrderStatus.cancelled)
          .length,
    };
  }
}
