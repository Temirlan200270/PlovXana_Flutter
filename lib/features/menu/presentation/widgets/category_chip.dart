import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.category, required this.onTap});

  static const BorderRadius _archRadius = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(16),
  );

  static IconData iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('плов')) return Icons.rice_bowl;
    if (n.contains('шашлык')) return Icons.outdoor_grill;
    if (n.contains('манты')) return Icons.dinner_dining;
    if (n.contains('самса')) return Icons.bakery_dining;
    if (n.contains('суп')) return Icons.soup_kitchen_rounded;
    if (n.contains('лагман')) return Icons.ramen_dining;
    if (n.contains('салат')) return Icons.eco;
    if (n.contains('закуск')) return Icons.tapas;
    if (n.contains('напит')) return Icons.local_cafe;
    if (n.contains('десерт')) return Icons.cake;
    if (n.contains('мясо') || n.contains('птиц')) return Icons.set_meal;
    return Icons.soup_kitchen_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final icon = iconForCategory(category.name);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: _archRadius,
                border: Border.all(
                  color: AppColors.accentBlue.withValues(alpha: 0.35),
                ),
              ),
              child: category.imageUrl != null
                  ? ClipRRect(
                      borderRadius: _archRadius,
                      child: CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Icon(
                          icon,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    )
                  : Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.cream,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
