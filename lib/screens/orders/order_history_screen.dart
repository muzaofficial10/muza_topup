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

  void _showCodeDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Enter Security Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check the email linked to this eFootball account for a code, then enter it below.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Security Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (codeCtrl.text.trim().isEmpty) return;
              await dialogContext
                  .read<OrderService>()
                  .submitVerificationCode(order.id, codeCtrl.text.trim());
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Submit', style: TextStyle(color: AppColors.neonBlue)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final needsCode = order.game == GameType.efootball &&
        (order.verificationCode == null || order.verificationCode!.isEmpty);
    final adminRequestedCode = needsCode && order.codeRequested;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: adminRequestedCode ? AppColors.warning.withOpacity(0.5) : Colors.white.withOpacity(0.06),
          width: adminRequestedCode ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (adminRequestedCode)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Admin needs your eFootball security code to complete this order',
                      style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
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
              Text(DateFormat('MMM d, y \u00b7 h:mm a').format(order.createdAt),
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
          if (needsCode) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCodeDialog(context),
                icon: const Icon(Icons.verified_user_rounded, size: 16),
                label: const Text('Submit Security Code'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: adminRequestedCode ? AppColors.warning : AppColors.processing),
                  foregroundColor: adminRequestedCode ? AppColors.warning : AppColors.processing,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
