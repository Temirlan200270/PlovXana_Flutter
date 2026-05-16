import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/menu_item.dart';
import '../../../cart/data/cart_provider.dart';

class ItemDetailScreen extends ConsumerWidget {
  final MenuItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.where((e) => e.item.id == item.id).firstOrNull;
    final quantity = cartItem?.quantity ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.isHalal)
                        _tag('Халяль', AppColors.halal),
                      if (item.isSpicy) ...[
                        const SizedBox(width: 8),
                        _tag('Острое 🌶', AppColors.spicy),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.name, style: Theme.of(context).textTheme.displaySmall),
                  if (item.weightG != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${item.weightG} г',
                      style: const TextStyle(color: AppColors.greyLight, fontSize: 14),
                    ),
                  ],
                  if (item.description != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        color: AppColors.greyLight,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    '${_fmt(item.price)} тг',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: quantity == 0
              ? ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).add(item);
                    Navigator.pop(context);
                  },
                  child: const Text('Добавить в корзину'),
                )
              : Row(
                  children: [
                    _CounterBtn(
                      icon: Icons.remove,
                      onTap: () => ref.read(cartProvider.notifier).remove(item.id),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$quantity шт · ${_fmt(item.price * quantity)} тг',
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    _CounterBtn(
                      icon: Icons.add,
                      onTap: () => ref.read(cartProvider.notifier).add(item),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(color: AppColors.surfaceVariant);
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  String _fmt(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.cream),
      ),
    );
  }
}
