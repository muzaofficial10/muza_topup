import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/supabase_client.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<double> _last7DaysRevenue = List.filled(7, 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = SupabaseService.client;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final rows = await client
        .from('orders')
        .select('amount, created_at')
        .gte('created_at', start.toIso8601String())
        .eq('status', 'completed');

    final buckets = List.filled(7, 0.0);
    for (final row in rows as List) {
      final date = DateTime.parse(row['created_at'] as String);
      final dayIndex = date.difference(start).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        buckets[dayIndex] += (row['amount'] as num).toDouble();
      }
    }
    if (mounted) setState(() {
      _last7DaysRevenue = buckets;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Revenue — Last 7 Days', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final day = DateTime.now().subtract(Duration(days: 6 - v.toInt()));
                              const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(names[day.weekday - 1],
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(7, (i) {
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: _last7DaysRevenue[i],
                            color: AppColors.neonBlue,
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('7-Day Total', style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                        '\$${_last7DaysRevenue.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tip: For deeper analytics (customer LTV, package popularity, '
                  'conversion rates), query the `orders` and `profiles` tables '
                  'directly from the Supabase Dashboard SQL editor or connect '
                  'a BI tool via the Supabase Postgres connection string.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
    );
  }
}
