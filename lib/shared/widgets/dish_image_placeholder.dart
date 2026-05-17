import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'ikat_pattern_background.dart';

/// Плейсхолдер фото блюда — казан вместо «вилки с ножом».
class DishImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final double iconSize;

  const DishImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return IkatPatternBackground(
      child: Container(
        width: width,
        height: height,
        color: AppColors.surfaceVariant,
        child: Center(
          child: Icon(
            Icons.soup_kitchen_rounded,
            size: iconSize,
            color: AppColors.divider,
          ),
        ),
      ),
    );
  }
}
