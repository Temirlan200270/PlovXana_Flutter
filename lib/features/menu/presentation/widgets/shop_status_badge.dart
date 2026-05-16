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
        : (open ? AppColors.halal : AppColors.error);

    final textColor = closingSoon
        ? AppColors.primary
        : (open ? AppColors.greyLight : AppColors.error);

    final text = closingSoon
        ? l10n.shopStatusClosingSoon()
        : (open ? l10n.shopStatusOpen() : l10n.shopStatusClosed());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
