import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/delivery_rules.dart';
import '../../../core/l10n/delivery_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dish_image_placeholder.dart';
import '../../../shared/widgets/ikat_pattern_background.dart';
import '../data/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartTitle),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: Text(l10n.cartClear,
                  style: const TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? IkatPatternBackground(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DishImagePlaceholder(width: 96, height: 96, iconSize: 48),
                    const SizedBox(height: 16),
                    Text(
                      l10n.cartEmpty,
                      style: const TextStyle(
                          color: AppColors.greyLight, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(l10n.cartGoToMenu),
                    ),
                  ],
                ),
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
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
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
                                  color: AppColors.cream,
                                  fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              l10n.currencyTenge(formatTenge(ci.item.price)),
                              style: const TextStyle(
                                  color: AppColors.greyLight, fontSize: 13),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.grey),
                            onPressed: () =>
                                ref.read(cartProvider.notifier).remove(ci.item.id),
                          ),
                          Text('${ci.quantity}',
                              style: const TextStyle(
                                  color: AppColors.cream, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: AppColors.primary),
                            onPressed: () =>
                                ref.read(cartProvider.notifier).add(ci.item),
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
                  child: Text(l10n.cartCheckout(formatTenge(total))),
                ),
              ),
            ),
    );
  }

  Widget _imgPlaceholder() {
    return const DishImagePlaceholder(width: 88, height: 88, iconSize: 32);
  }
}
