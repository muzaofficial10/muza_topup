import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = AppConstants.faqs[i];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: AppColors.card,
              collapsedBackgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              iconColor: AppColors.neonBlue,
              collapsedIconColor: AppColors.textMuted,
              title: Text(item['q']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item['a']!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
