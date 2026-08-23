with open('lib/screens/orders/order_history_screen.dart') as f:
    c = f.read()

old1 = """          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.game.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('\\$${order.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}"""

new1 = """          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.game.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('\\$${order.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 15)),
            ],
          ),
          if (order.game == GameType.efootball &&
              order.status == OrderStatus.pending &&
              (order.verificationCode == null || order.verificationCode!.isEmpty)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCodeDialog(context),
                icon: const Icon(Icons.verified_user_rounded, size: 16),
                label: const Text('Submit Security Code'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.processing),
                  foregroundColor: AppColors.processing,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCodeDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Enter Security Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Check the email linked to this eFootball account for a code, then enter it below.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Security Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (codeCtrl.text.trim().isEmpty) return;
              await dialogContext.read<OrderService>().submitVerificationCode(order.id, codeCtrl.text.trim());
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Submit', style: TextStyle(color: AppColors.neonBlue)),
          ),
        ],
      ),
    );
  }
}"""

print("orderhist anchor:", old1 in c)
c = c.replace(old1, new1, 1)

with open('lib/screens/orders/order_history_screen.dart', 'w') as f:
    f.write(c)
print("order_history_screen.dart done")

