import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../data/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: const Text('Очистить', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  const Text('Корзина пуста', style: TextStyle(color: AppColors.greyLight, fontSize: 18)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Перейти в меню'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final ci = cart[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        child: ci.item.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: ci.item.imageUrl!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => _imgPlaceholder(),
                              )
                            : _imgPlaceholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ci.item.name,
                              style: const TextStyle(
                                  color: AppColors.cream, fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_fmt(ci.item.price)} тг',
                              style: const TextStyle(color: AppColors.greyLight, fontSize: 13),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.grey),
                            onPressed: () =>
                                ref.read(cartProvider.notifier).remove(ci.item.id),
                          ),
                          Text('${ci.quantity}',
                              style: const TextStyle(color: AppColors.cream, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () => ref.read(cartProvider.notifier).add(ci.item),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => context.push('/checkout'),
                  child: Text('Оформить · ${_fmt(total)} тг'),
                ),
              ),
            ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
        width: 88,
        height: 88,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.restaurant, color: AppColors.grey));
  }

  String _fmt(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}
