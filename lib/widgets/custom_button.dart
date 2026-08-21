import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool gold;
  final IconData? icon;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.gold = false,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: const BorderSide(color: AppColors.neonBlue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label, style: const TextStyle(color: AppColors.neonBlue, fontWeight: FontWeight.w700)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: gold ? AppColors.goldButtonGradient : AppColors.neonButtonGradient,
        boxShadow: [
          BoxShadow(
            color: (gold ? AppColors.gold : AppColors.neonBlue).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: loading ? null : onPressed,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.black, size: 19),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
