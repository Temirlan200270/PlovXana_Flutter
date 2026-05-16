import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/menu_item.dart';
import '../../../../shared/widgets/dish_image_placeholder.dart';
import '../../../cart/data/cart_provider.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.where((e) => e.item.id == item.id).firstOrNull;
    final inCart = cartItem != null;
    final quantity = cartItem?.quantity ?? 0;

    return GestureDetector(
      onTap: () => context.push('/item/${item.id}', extra: item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: item.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => const DishImagePlaceholder(
                              iconSize: 48,
                            ),
                          )
                        : const DishImagePlaceholder(iconSize: 48),
                  ),
                  if (item.isHalal)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _badge('Халяль', AppColors.halal),
                    ),
                  if (item.isSpicy)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _badge('Острое', AppColors.spicy),
                    ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 80),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.weightG != null ? '${item.weightG} г' : '',
                      style: const TextStyle(color: AppColors.greyLight, fontSize: 10),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${_formatPrice(item.price)} тг',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _CartControl(
                          inCart: inCart,
                          quantity: quantity,
                          onAdd: () => ref.read(cartProvider.notifier).add(item),
                          onRemove: () => ref.read(cartProvider.notifier).remove(item.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.cream, fontSize: 10)),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}

class _CartControl extends StatelessWidget {
  final bool inCart;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartControl({
    required this.inCart,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (!inCart) {
      return GestureDetector(
        onTap: onAdd,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 16, color: AppColors.cream),
        ),
      );
    }

    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepButton(Icons.remove, onRemove),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _stepButton(Icons.add, onAdd),
          ],
        ),
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(icon, size: 16, color: AppColors.background),
      ),
    );
  }
}
