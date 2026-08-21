import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.processing:
        return AppColors.processing;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.danger;
    }
  }

  IconData get _icon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.processing:
        return Icons.autorenew_rounded;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 5),
          Text(status.label,
              style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
