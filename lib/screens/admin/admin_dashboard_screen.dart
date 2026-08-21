import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await context.read<OrderService>().getDashboardStats();
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<AuthService>().signOut();
              if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.neonBlue,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  label: "Today's Orders",
                  value: '${_stats?['daily_orders'] ?? '--'}',
                  icon: Icons.today_rounded,
                  color: AppColors.neonBlue,
                ),
                _StatCard(
                  label: 'This Week',
                  value: '${_stats?['weekly_orders'] ?? '--'}',
                  icon: Icons.calendar_view_week_rounded,
                  color: AppColors.processing,
                ),
                _StatCard(
                  label: 'Monthly Revenue',
                  value: '\$${(_stats?['monthly_revenue'] ?? 0.0).toStringAsFixed(2)}',
                  icon: Icons.attach_money_rounded,
                  color: AppColors.gold,
                ),
                _StatCard(
                  label: 'Total Customers',
                  value: '${_stats?['total_customers'] ?? '--'}',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Manage', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            _AdminMenuTile(
              icon: Icons.receipt_long_rounded,
              label: 'Orders',
              subtitle: 'View, approve, reject & update orders',
              onTap: () => Navigator.of(context).pushNamed('/admin/orders'),
            ),
            _AdminMenuTile(
              icon: Icons.inventory_2_rounded,
              label: 'Products',
              subtitle: 'Manage UC & Coin packages and prices',
              onTap: () => Navigator.of(context).pushNamed('/admin/products'),
            ),
            _AdminMenuTile(
              icon: Icons.bar_chart_rounded,
              label: 'Reports',
              subtitle: 'Daily, weekly & monthly analytics',
              onTap: () => Navigator.of(context).pushNamed('/admin/reports'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final VoidCallback onTap;
  const _AdminMenuTile({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
