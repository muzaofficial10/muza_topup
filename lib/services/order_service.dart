import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/order_model.dart';

class OrderService {
  final _client = SupabaseService.client;

  Future<OrderModel> createOrder(OrderModel order) async {
    final data = await _client
        .from('orders')
        .insert(order.toInsertJson())
        .select()
        .single();
    return OrderModel.fromJson(data);
  }

  Future<List<OrderModel>> getMyOrders() async {
    final data = await _client
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }
  Stream<List<OrderModel>> watchMyOrders(String userId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((e) => OrderModel.fromJson(e)).toList());
  }

  Future<void> submitVerificationCode(String orderId, String code) async {
    await _client.from('orders').update({
      'verification_code': code,
      'status': OrderStatus.processing.name,
      'code_requested': false,
    }).eq('id', orderId);
  }

  Future<void> requestVerificationCode(String orderId) async {
    await _client.from('orders').update({
      'code_requested': true,
    }).eq('id', orderId);
  }
  Future<List<OrderModel>> getAllOrders({
    OrderStatus? status,
    GameType? game,
    String? searchQuery,
  }) async {
    var query = _client.from('orders').select();
    if (status != null) query = query.eq('status', status.name);
    if (game != null) query = query.eq('game', game.name);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'player_id.ilike.%$searchQuery%,efootball_email.ilike.%$searchQuery%,id.ilike.%$searchQuery%',
      );
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? note}) async {
    await _client.from('orders').update({
      'status': status.name,
      if (note != null) 'admin_note': note,
    }).eq('id', orderId);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(today.year, today.month, 1).toIso8601String();

    final daily = await _client
        .from('orders')
        .select('id')
        .gte('created_at', startOfDay)
        .count();
    final weekly = await _client
        .from('orders')
        .select('id')
        .gte('created_at', startOfWeek.toIso8601String())
        .count();
    final monthlyRevenue = await _client
        .from('orders')
        .select('amount')
        .gte('created_at', startOfMonth)
        .eq('status', 'completed');

    double revenue = 0;
    for (final row in monthlyRevenue as List) {
      revenue += (row['amount'] as num).toDouble();
    }

    final totalCustomers = await _client.from('profiles').select('id').count();

    return {
      'daily_orders': daily.count,
      'weekly_orders': weekly.count,
      'monthly_revenue': revenue,
      'total_customers': totalCustomers.count,
    };
  }
}
