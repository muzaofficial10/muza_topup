import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/storage_service.dart';
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

  /// Builds an EVC Plus / eDahab style USSD string that includes the
  /// amount, e.g. *712*614457264*10*5# for $10.05 via EVC Plus.
  String _buildUssdCode(double amount) {
    final whole = amount.floor();
    final cents = ((amount - whole) * 100).round();
    final prefix = _paymentMethod == 'eDahab' ? '*880' : '*712';
    if (cents == 0) {
      return '$prefix*${AppConstants.paymentNumber}*$whole#';
    }
    return '$prefix*${AppConstants.paymentNumber}*$whole*$cents#';
  }

  Future<void> _sendPayment() async {
    if (_selectedIndex == -1) {
      _snack('Please select a Coin package first');
      return;
    }
    final price = (AppConstants.efootballPackages[_selectedIndex]['price'] as num).toDouble();
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
      _snack('Please select a Coin p
