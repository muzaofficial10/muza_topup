import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = [
    ('Information We Collect', 'We collect your name, phone number, email, PUBG UID, '
        'and — only when placing an eFootball order — your eFootball login credentials, '
        'strictly to process your top-up order.'),
    ('How We Use Your Information', 'Your information is used solely to fulfil your order, '
        'communicate order status, and provide customer support. We do not sell or share '
        'your data with third parties.'),
    ('eFootball Credentials', 'Your eFootball login information will only be used to '
        'complete your order and will not be shared with third parties. Access is limited '
        'to authorized staff processing your order.'),
    ('Payment Screenshots', 'Screenshots are stored securely and used only to verify '
        'payment. They are visible only to you and authorized administrators.'),
    ('Data Security', 'We use Supabase with Row Level Security to ensure your data is only '
        'accessible to you and authorized administrators.'),
    ('Your Rights', 'You may request deletion of your account and associated data at any '
        'time by contacting support.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, i) {
          final (title, body) = _sections[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.gold)),
              const SizedBox(height: 6),
              Text(body, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
            ],
          );
        },
      ),
    );
  }
}
