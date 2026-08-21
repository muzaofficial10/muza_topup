import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    ('1. Orders', 'All orders are subject to verification of payment before processing. '
        'Please ensure your Player UID or eFootball credentials are entered correctly — '
        'Muza Top-Up is not responsible for top-ups sent to an incorrect account.'),
    ('2. Payments', 'Payments must be made in full via one of our listed payment methods '
        '(ZAAD, eDahab, Sahal Pay) before an order can be processed.'),
    ('3. Delivery Time', 'Most orders are completed within 5-30 minutes. Delays may occur '
        'during high-volume periods or payment verification issues.'),
    ('4. Refunds', 'Refunds are issued only for orders that cannot be fulfilled due to an '
        'error on our part. Orders cancelled after processing has begun are not eligible.'),
    ('5. Account Responsibility', 'You are responsible for the accuracy of the account '
        'information you provide, including PUBG UID and eFootball login credentials.'),
    ('6. Service Availability', 'We reserve the right to suspend or modify the service at '
        'any time without prior notice.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, i) {
          final (title, body) = _sections[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.neonBlue)),
              const SizedBox(height: 6),
              Text(body, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
            ],
          );
        },
      ),
    );
  }
}
