import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/menu_providers.dart';
import '../widgets/category_chip.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/promo_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final popularAsync = ref.watch(popularItemsProvider);
    final promotionsAsync = ref.watch(promotionsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 60,
            title: Column(
              children: [
                Text(
                  'ПЛОВ НОМЕР 1',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                const Text(
                  'Узбекская кухня · Павлодар',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.greyLight,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.cream),
                onPressed: () => _showInfo(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: promotionsAsync.when(
              data: (promos) => promos.isEmpty
                  ? const SizedBox.shrink()
                  : PromoBanner(promotions: promos),
              loading: () => const SizedBox(height: 160),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Категории',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (cats) => SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cats.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => CategoryChip(
                    category: cats[i],
                    onTap: () => context.push(
                      '/category/${cats[i].id}',
                      extra: cats[i],
                    ),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Ошибка загрузки', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Популярное',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          popularAsync.when(
            data: (items) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => MenuItemCard(item: items[i]),
                  childCount: items.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ПЛОВ НОМЕР 1',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.location_on_outlined,
                'ТЦ Saida Plaza, пр. Нурсултана Назарбаева, 60/5, 1 этаж'),
            _infoRow(Icons.access_time_outlined,
                'Ежедневно 11:00–24:00\nПоследний заказ: 22:45'),
            _infoRow(Icons.phone_outlined, '+7 777 400 77 28 — бронирование'),
            _infoRow(Icons.delivery_dining_outlined, '+7 707 400 77 28 — доставка'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.cream, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
