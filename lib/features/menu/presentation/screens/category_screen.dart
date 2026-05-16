import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/menu_providers.dart';
import '../widgets/menu_item_card.dart';

class CategoryScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(menuItemsByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: itemsAsync.when(
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.no_food_outlined, size: 64, color: AppColors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Всё временно в стоп-листе',
                        style: TextStyle(
                          color: AppColors.cream,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Попробуйте другую категорию\nили загляните позже — мы пополняем меню каждый день',
                        style: TextStyle(
                          color: AppColors.greyLight,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => MenuItemCard(item: items[i]),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Ошибка: $e', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}
