import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/order_status_badge.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;
  OrderStatus? _statusFilter;
  GameType? _gameFilter;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final orders = await context.read<OrderService>().getAllOrders(
          status: _statusFilter,
          game: _gameFilter,
          searchQuery: _searchCtrl.text.trim(),
        );
    if (mounted) setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Future<void> _updateStatus(OrderModel order, OrderStatus status) async {
    await context.read<OrderService>().updateOrderStatus(order.id, status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Search by UID, email or Order ID',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _load),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(label: 'All', selected: _statusFilter == null, onTap: () {
                  setState(() => _statusFilter = null);
                  _load();
                }),
                for (final s in OrderStatus.values)
                  _FilterChip(
                    label: s.label,
                    selected: _statusFilter == s,
                    onTap: () {
                      setState(() => _statusFilter = s);
                      _load();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
                : _orders.isEmpty
                    ? const Center(child: Text('No orders found', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _AdminOrderCard(
                          order: _orders[i],
                          onStatusChange: (s) => _updateStatus(_orders[i], s),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.neonBlue.withOpacity(0.2),
        backgroundColor: AppColors.card,
        labelStyle: TextStyle(color: selected ? AppColors.neonBlue : AppColors.textSecondary, fontSize: 12),
        side: BorderSide(color: selected ? AppColors.neonBlue : Colors.white.withOpacity(0.08)),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<OrderStatus> onStatusChange;
  const _AdminOrderCard({required this.order, required this.onStatusChange});

  Future<void> _viewScreenshot(BuildContext context) async {
    if (order.paymentScreenshotUrl == null) return;
    final url = await context.read<StorageService>().getSignedUrl(order.paymentScreenshotUrl!);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(child: Image.network(url)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPubg = order.game == GameType.pubg;
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
              Icon(isPubg ? Icons.sports_esports_rounded : Icons.sports_soccer_rounded,
                  color: isPubg ? AppColors.neonBlue : AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(order.packageName, style: const TextStyle(fontWeight: FontWeight.w800))),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('Order #${order.id.substring(0, order.id.length >= 8 ? 8 : order.id.length)} · ${DateFormat('MMM d, h:mm a').format(order.createdAt)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const Divider(height: 20),
          if (isPubg)
            _InfoRow(label: 'PUBG UID', value: order.playerId ?? '—')
          else ...[
            _InfoRow(label: 'Email', value: order.efootballEmail ?? '—'),
            _InfoRow(label: 'Password', value: order.efootballPassword ?? '—', sensitive: true),
          ],
          _InfoRow(label: 'Amount', value: '\$${order.amount.toStringAsFixed(2)}'),
          _InfoRow(label: 'Payment Method', value: order.paymentMethod),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewScreenshot(context),
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: const Text('Screenshot'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.neonBlue),
                    foregroundColor: AppColors.neonBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionBtn(label: 'Processing', color: AppColors.processing, onTap: () => onStatusChange(OrderStatus.processing)),
              _ActionBtn(label: 'Completed', color: AppColors.success, onTap: () => onStatusChange(OrderStatus.completed)),
              _ActionBtn(label: 'Cancel', color: AppColors.danger, onTap: () => onStatusChange(OrderStatus.cancelled)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool sensitive;
  const _InfoRow({required this.label, required this.value, this.sensitive = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: sensitive ? AppColors.danger : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
