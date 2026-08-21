import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openWhatsapp() async {
    final uri = Uri.parse(
        'https://wa.me/${AppConstants.whatsappCountryCode}${AppConstants.whatsappNumber}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, gradient: AppColors.neonButtonGradient),
                            child: const Icon(Icons.bolt_rounded, color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          const Text('MUZA TOP-UP',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1)),
                        ],
                      ),
                      const Spacer(),
                      const Text('Instant Top-Ups.\nZero Hassle.',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
                      const SizedBox(height: 6),
                      const Text('PUBG Mobile UC & eFootball Coins delivered fast.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.receipt_long_rounded),
                onPressed: () => Navigator.of(context).pushNamed('/orders'),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () async {
                  await context.read<AuthService>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                  }
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _GameCard(
                        title: 'PUBG Mobile',
                        subtitle: 'UC Top-Up',
                        icon: Icons.sports_esports_rounded,
                        gradient: AppColors.neonButtonGradient,
                        onTap: () => Navigator.of(context).pushNamed('/topup/pubg'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _GameCard(
                        title: 'eFootball',
                        subtitle: 'Coins Top-Up',
                        icon: Icons.sports_soccer_rounded,
                        gradient: AppColors.goldButtonGradient,
                        onTap: () => Navigator.of(context).pushNamed('/topup/efootball'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _QuickAction(
                  icon: Icons.receipt_long_rounded,
                  label: 'Order History',
                  onTap: () => Navigator.of(context).pushNamed('/orders'),
                ),
                _QuickAction(
                  icon: Icons.support_agent_rounded,
                  label: 'Contact Support (WhatsApp)',
                  onTap: _openWhatsapp,
                ),
                _QuickAction(
                  icon: Icons.help_outline_rounded,
                  label: 'FAQ',
                  onTap: () => Navigator.of(context).pushNamed('/faq'),
                ),
                _QuickAction(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () => Navigator.of(context).pushNamed('/terms'),
                ),
                _QuickAction(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => Navigator.of(context).pushNamed('/privacy'),
                ),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Customer Reviews'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _ReviewCard(name: 'Ahmed K.', review: 'Fast delivery, UC arrived in 10 minutes!', rating: 5),
                      _ReviewCard(name: 'Faadumo A.', review: 'Trusted seller, great prices on coins.', rating: 5),
                      _ReviewCard(name: 'Yusuf M.', review: 'Smooth process and quick support replies.', rating: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Payment Info'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded, color: AppColors.gold, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Send payment to: ${AppConstants.paymentNumber}',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(AppConstants.paymentMethods.join(' · '),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.card,
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: gradient),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: const [
                Text('Top Up Now', style: TextStyle(color: AppColors.neonBlue, fontWeight: FontWeight.w700, fontSize: 12)),
                Icon(Icons.arrow_forward_rounded, color: AppColors.neonBlue, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800));
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.neonBlue, size: 20),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name, review;
  final int rating;
  const _ReviewCard({required this.name, required this.review, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              ...List.generate(
                rating,
                (i) => const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(review,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
