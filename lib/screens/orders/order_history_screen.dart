import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../widgets/order_status_badge.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final Stream<List<OrderModel>> _stream;

  @override
  void initState() {
    super.initState();
    final userId = SupabaseService.currentUser!.id;
    _stream = context.read<OrderService>().watchMyOrders(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder<List<OrderModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.neonBlue));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No orders yet', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderTile(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                order.game == GameType.pubg ? Icons.sports_esports_rounded : Icons.sports_soccer_rounded,
                color: order.game == GameType.pubg ? AppColors.neonBlue : AppColors.gold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(order.packageName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Order #${order.id.substring(0, order.id.length >= 8 ? 8 : order.id.length)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const Spacer(),
              Text(DateFormat('MMM d, y · h:mm a').format(order.createdAt),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.game.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('\$${order.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
