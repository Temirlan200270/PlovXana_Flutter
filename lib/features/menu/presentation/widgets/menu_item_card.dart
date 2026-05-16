import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/menu_item.dart';
import '../../../cart/data/cart_provider.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.where((e) => e.item.id == item.id).firstOrNull;
    final inCart = cartItem != null;

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
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: item.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => _placeholder(),
                          )
                        : _placeholder(),
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
                      child: _badge('🌶', Colors.transparent),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                      GestureDetector(
                        onTap: () => ref.read(cartProvider.notifier).add(item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: inCart ? AppColors.primary : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            inCart ? Icons.check : Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.restaurant, color: AppColors.grey, size: 40),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}
