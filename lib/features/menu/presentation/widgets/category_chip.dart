import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.category, required this.onTap});

  static IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('плов'))    return Icons.rice_bowl;
    if (n.contains('шашлык')) return Icons.outdoor_grill;
    if (n.contains('манты'))  return Icons.dinner_dining;
    if (n.contains('самса'))  return Icons.bakery_dining;
    if (n.contains('суп'))    return Icons.soup_kitchen;
    if (n.contains('лагман')) return Icons.ramen_dining;
    if (n.contains('салат'))  return Icons.eco;
    if (n.contains('закуск')) return Icons.tapas;
    if (n.contains('напит'))  return Icons.local_cafe;
    if (n.contains('десерт')) return Icons.cake;
    if (n.contains('мясо') || n.contains('птиц')) return Icons.set_meal;
    return Icons.restaurant_menu;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: category.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Icon(
                          _iconForCategory(category.name),
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(_iconForCategory(category.name), color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(
                color: AppColors.cream,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
