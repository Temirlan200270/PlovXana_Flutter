import 'package:flutter/material.dart';
import '../../../../core/config/delivery_rules.dart';
import '../../../../core/l10n/delivery_l10n.dart';
import '../../../../core/theme/app_colors.dart';

class ShopStatusBadge extends StatelessWidget {
  const ShopStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final open = isShopOpen();
    final closingSoon = isClosingSoon();

    final dotColor = closingSoon
        ? AppColors.primary
        : (open ? AppColors.statusOpen : AppColors.error);

    final text = closingSoon
        ? l10n.shopStatusClosingSoon()
        : (open ? l10n.shopStatusOpen() : l10n.shopStatusClosed());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: dotColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
