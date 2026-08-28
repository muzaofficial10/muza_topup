import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../models/order_model.dart';
import '../../models/package_model.dart';
import '../../services/order_service.dart';
import '../../services/storage_service.dart';
import '../../services/product_service.dart';
import '../../widgets/package_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/screenshot_uploader.dart';

class EfootballTopupScreen extends StatefulWidget {
  const EfootballTopupScreen({super.key});
  @override
  State<EfootballTopupScreen> createState() => _EfootballTopupScreenState();
}

class _EfootballTopupScreenState extends State<EfootballTopupScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _obscure = true;
  int _selectedIndex = -1;
  String _paymentMethod = AppConstants.paymentMethods.first;
  File? _screenshot;
  bool _submitting = false;
  bool _loadingPackages = true;
  List<PackageModel> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final pkgs = await context.read<ProductService>().getPackages(GameType.efootball);
    if (mounted) setState(() {
      _packages = pkgs;
      _loadingPackages = false;
    });
  }
  String _buildUssdCode(double amount) {
    final whole = amount.floor();
    final cents = ((amount - whole) * 100).round();
    final prefix = _paymentMethod == 'eDahab' ? '*880' : '*712';
    if (cents == 0) return '$prefix*${AppConstants.paymentNumber}*$whole#';
    return '$prefix*${AppConstants.paymentNumber}*$whole*$cents#';
  }

  Future<void> _sendPayment() async {
    if (_selectedIndex == -1) {
      _snack('Please select a Coin package first');
      return;
    }
    final price = _packages[_selectedIndex].price;
    final code = _buildUssdCode(price);
    final uri = Uri.parse('tel:${Uri.encodeComponent(code)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Could not open dialer');
    }
  }
  Future<void> _submit() async {
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      _snack('Please enter a valid eFootball email');
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      _snack('Please enter your eFootball password');
      return;
    }
    if (_selectedIndex == -1) {
      _snack('Please select a Coin package');
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

      final pkg = _packages[_selectedIndex];
      final order = OrderModel(
        id: '',
        userId: userId,
        game: GameType.efootball,
        efootballEmail: _emailCtrl.text.trim(),
        efootballPassword: _passwordCtrl.text,
        packageName: pkg.name,
        packageAmount: pkg.amount,
        amount: pkg.price,
        paymentScreenshotUrl: path,
        paymentMethod: _paymentMethod,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        verificationCode: _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
      );

      await context.read<OrderService>().createOrder(order);
      if (!mounted) return;
      _passwordCtrl.clear();
      _showSuccessDialog();
    } catch (e) {
      _snack('Failed to submit order: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
    final selectedPrice = _selectedIndex == -1 || _packages.isEmpty ? 0.0 : _packages[_selectedIndex].price;

    return Scaffold(
      appBar: AppBar(title: const Text('eFootball Coins Top-Up')),
      body: _loadingPackages
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gold.withOpacity(0.35))),
            child: Row(children: [
              const Icon(Icons.shield_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(AppConstants.efootballSecurityNotice, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 20),
          TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'eFootball Email', prefixIcon: Icon(Icons.email_outlined))),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(labelText: 'eFootball Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted), onPressed: () => setState(() => _obscure = !_obscure))),
          ),
          const SizedBox(height: 14),
          TextField(controller: _codeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Security Code (if you already have one)', hintText: 'Leave blank if not received yet', prefixIcon: Icon(Icons.verified_user_rounded))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.processing.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.processing.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.mark_email_read_rounded, color: AppColors.processing, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text("eFootball may email you a security code after we start the top-up. You can add it later from Order History if you don't have it yet.", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 22),
          const Text('Select Coin Package', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          if (_packages.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No packages available right now.', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ...List.generate(_packages.length, (i) {
            final pkg = _packages[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PackageCard(title: pkg.name, subtitle: 'eFootball Coins', price: pkg.price, icon: Icons.sports_soccer_rounded, selected: _selectedIndex == i, onTap: () => setState(() => _selectedIndex = i)),
            );
          }),
          const SizedBox(height: 22),
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: AppConstants.paymentMethods.map((m) {
              final selected = _paymentMethod == m;
              return ChoiceChip(label: Text(m), selected: selected, onSelected: (_) => setState(() => _paymentMethod = m), selectedColor: AppColors.neonBlue.withOpacity(0.2), backgroundColor: AppColors.card, labelStyle: TextStyle(color: selected ? AppColors.neonBlue : AppColors.textSecondary), side: BorderSide(color: selected ? AppColors.neonBlue : Colors.white.withOpacity(0.08)));
            }).toList(),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text('Send payment to ${AppConstants.paymentNumber} via $_paymentMethod', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5))),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(onPressed: _sendPayment, icon: const Icon(Icons.call_rounded, size: 16), label: const Text('Send Payment Now'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), foregroundColor: AppColors.gold)),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          const Text('Payment Screenshot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          ScreenshotUploader(onChanged: (f) => setState(() => _screenshot = f)),
          const SizedBox(height: 24),
          if (selectedPrice > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(color: AppColors.textSecondary)),
                Text('\$${selectedPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gold)),
              ]),
            ),
          CustomButton(label: 'Submit Order', onPressed: _submit, loading: _submitting, gold: true, icon: Icons.send_rounded),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
