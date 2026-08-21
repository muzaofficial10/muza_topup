import 'package:flutter/material.dart';
import '../core/theme.dart';

class PackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double price;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  const PackageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
    this.icon = Icons.diamond_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonBlue.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.neonBlue : Colors.white.withOpacity(0.07),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.neonBlue.withOpacity(0.25), blurRadius: 16)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (selected ? AppColors.neonBlue : AppColors.gold).withOpacity(0.15),
              ),
              child: Icon(icon, color: selected ? AppColors.neonBlue : AppColors.gold, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text('\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.gold)),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.neonBlue : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
