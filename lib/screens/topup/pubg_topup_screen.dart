import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/package_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/screenshot_uploader.dart';

class PubgTopupScreen extends StatefulWidget {
  const PubgTopupScreen({super.key});

  @override
  State<PubgTopupScreen> createState() => _PubgTopupScreenState();
}

class _PubgTopupScreenState extends State<PubgTopupScreen> {
  final _uidCtrl = TextEditingController();
  int _selectedIndex = -1;
  String _paymentMethod = AppConstants.paymentMethods.first;
  File? _screenshot;
  bool _submitting = false;

  Future<void> _submit() async {
    if (_uidCtrl.text.trim().isEmpty) {
      _snack('Please enter your PUBG UID');
      return;
    }
    if (_selectedIndex == -1) {
      _snack('Please select a UC package');
      return;
    }
    if (_screenshot == null) {
      _snack('Please upload your payment screenshot');
      return;
    }

    setState(() => _submitting = true);
    try {
      final userId = SupabaseService.currentUser!.id;
      final storage = context.read<StorageService>();
      final path = await storage.uploadScreenshot(_screenshot!, userId);

      final pkg = AppConstants.pubgPackages[_selectedIndex];
      final order = OrderModel(
        id: '',
        userId: userId,
        game: GameType.pubg,
        playerId: _uidCtrl.text.trim(),
        packageName: pkg['name'] as String,
        packageAmount: pkg['amount'] as int,
        amount: (pkg['price'] as num).toDouble(),
        paymentScreenshotUrl: path,
        paymentMethod: _paymentMethod,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      await context.read<OrderService>().createOrder(order);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      _snack('Failed to submit order: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 10),
            Text('Order Submitted'),
          ],
        ),
        content: const Text(
          'Your order has been received and is pending verification. '
          'You can track its status in Order History.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/orders');
            },
            child: const Text('View Orders', style: TextStyle(color: AppColors.neonBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPrice = _selectedIndex == -1
        ? 0.0
        : (AppConstants.pubgPackages[_selectedIndex]['price'] as num).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('PUBG UC Top-Up')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _uidCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PUBG Mobile UID',
              hintText: 'e.g. 5123456789',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 22),
          const Text('Select UC Package', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ...List.generate(AppConstants.pubgPackages.length, (i) {
            final pkg = AppConstants.pubgPackages[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PackageCard(
                title: pkg['name'] as String,
                subtitle: 'PUBG Mobile UC',
                price: (pkg['price'] as num).toDouble(),
                selected: _selectedIndex == i,
                onTap: () => setState(() => _selectedIndex = i),
              ),
            );
          }),
          const SizedBox(height: 22),
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: AppConstants.paymentMethods.map((m) {
              final selected = _paymentMethod == m;
              return ChoiceChip(
                label: Text(m),
                selected: selected,
                onSelected: (_) => setState(() => _paymentMethod = m),
                selectedColor: AppColors.neonBlue.withOpacity(0.2),
                backgroundColor: AppColors.card,
                labelStyle: TextStyle(color: selected ? AppColors.neonBlue : AppColors.textSecondary),
                side: BorderSide(color: selected ? AppColors.neonBlue : Colors.white.withOpacity(0.08)),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Send payment to ${AppConstants.paymentNumber} via $_paymentMethod',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Payment Screenshot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          ScreenshotUploader(onChanged: (f) => setState(() => _screenshot = f)),
          const SizedBox(height: 24),
          if (selectedPrice > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(color: AppColors.textSecondary)),
                  Text('\$${selectedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
                ],
              ),
            ),
          CustomButton(label: 'Submit Order', onPressed: _submit, loading: _submitting, icon: Icons.send_rounded),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
