import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ShopStatusBadge extends StatelessWidget {
  const ShopStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOpen = now.hour >= 11 && now.hour < 24;
    final isClosingSoon = now.hour == 23 && now.minute >= 30;

    final dotColor = isClosingSoon
        ? AppColors.primary
        : (isOpen ? AppColors.halal : AppColors.error);

    final textColor = isClosingSoon
        ? AppColors.primary
        : (isOpen ? AppColors.greyLight : AppColors.error);

    final text = isClosingSoon
        ? 'Закроется скоро'
        : (isOpen ? 'Сейчас открыто' : 'Закрыто до 11:00');

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
