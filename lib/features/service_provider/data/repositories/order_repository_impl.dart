import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final SupabaseClient _supabase;

  OrderRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  @override
  Future<List<OrderEntity>> getProviderOrders({OrderStatus? status}) async {
    var query = _supabase
        .from('orders')
        .select('*, client:users!client_id(name), offer:offers(title)')
        .eq('provider_id', _userId);

    if (status != null) {
      query = query.eq('status', status.name);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrderEntity>> getClientOrders({OrderStatus? status}) async {
    var query = _supabase
        .from('orders')
        .select('*, offer:offers(title)')
        .eq('client_id', _userId);

    if (status != null) {
      query = query.eq('status', status.name);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<OrderEntity?> getOrderById(String id) async {
    final response = await _supabase
        .from('orders')
        .select('*, client:users!client_id(name), offer:offers(title)')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return OrderModel.fromJson(response);
  }

  @override
  Future<OrderEntity> createOrder({
    String? offerId,
    required String channelId,
    required String providerId,
    double? proposedPrice,
    String? clientNotes,
    bool isCustom = false,
  }) async {
    final model = OrderModel(
      id: '',
      offerId: offerId,
      channelId: channelId,
      clientId: _userId,
      providerId: providerId,
      status: OrderStatus.pending,
      proposedPrice: proposedPrice,
      clientNotes: clientNotes,
      isCustom: isCustom,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _supabase
        .from('orders')
        .insert(model.toInsertJson())
        .select()
        .single();

    return OrderModel.fromJson(response);
  }

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    await _supabase.from('orders').update({'status': status.name}).eq('id', id);
  }

  @override
  Future<void> addProviderNotes(String id, String notes) async {
    await _supabase
        .from('orders')
        .update({'provider_notes': notes})
        .eq('id', id);
  }

  @override
  Future<int> getActiveOrdersCount() async {
    final response = await _supabase
        .from('orders')
        .select('id')
        .eq('provider_id', _userId)
        .inFilter('status', ['pending', 'accepted']);

    return (response as List).length;
  }

  @override
  Future<double> getTotalRevenue() async {
    final response = await _supabase
        .from('orders')
        .select('proposed_price')
        .eq('provider_id', _userId)
        .eq('status', 'completed');

    double total = 0;
    for (final row in response as List) {
      if (row['proposed_price'] != null) {
        total += (row['proposed_price'] as num).toDouble();
      }
    }
    return total;
  }
}
