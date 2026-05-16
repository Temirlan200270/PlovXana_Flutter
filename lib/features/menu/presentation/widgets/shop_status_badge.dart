import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ShopStatusBadge extends StatelessWidget {
  const ShopStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOpen = now.hour >= 11 && now.hour < 24;
    final isClosingSoon = now.hour == 23 && now.minute >= 30;

    final color = isClosingSoon 
        ? Colors.orange 
        : (isOpen ? AppColors.halal : AppColors.error);
    
    final text = isClosingSoon 
        ? 'Закроется скоро' 
        : (isOpen ? 'Сейчас открыто' : 'Закрыто до 11:00');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
