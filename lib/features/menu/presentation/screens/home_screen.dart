import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/menu_providers.dart';
import '../widgets/category_chip.dart';
import '../widgets/menu_item_card.dart';
import '../../../../shared/models/menu_item.dart';
import '../widgets/menu_shimmer.dart';
import '../widgets/promo_banner.dart';
import '../widgets/shop_status_badge.dart';
import '../../../../shared/widgets/delivery_info_banner.dart';
import '../../../../shared/widgets/delivery_info_sheet.dart';
import '../../../../shared/widgets/ikat_pattern_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final popularAsync = ref.watch(popularItemsProvider);
    final newItemsAsync = ref.watch(newItemsProvider);
    final promotionsAsync = ref.watch(promotionsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);

    final isLoading = categoriesAsync.isLoading || popularAsync.isLoading;

    if (isLoading && searchQuery.isEmpty) {
      return const Scaffold(body: SafeArea(child: MenuShimmer()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 72,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ПЛОВ НОМЕР 1',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      const ShopStatusBadge(),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.local_shipping_outlined, color: AppColors.cream),
                onPressed: () => showDeliveryInfoSheet(context),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                onPressed: () => _showLogoutConfirm(context),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.cream),
                onPressed: () => _showInfo(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: IkatPatternBackground(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                style: const TextStyle(color: AppColors.cream),
                decoration: InputDecoration(
                  hintText: 'Поиск блюд...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: AppColors.grey),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            _buildSearchResults(searchResultsAsync)
          else ...[
            SliverToBoxAdapter(
              child: promotionsAsync.when(
                data: (promos) => promos.isEmpty
                    ? const SizedBox.shrink()
                    : PromoBanner(promotions: promos),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
            const SliverToBoxAdapter(child: DeliveryInfoBanner()),
            _buildSectionTitle('Категории'),
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (cats) => SizedBox(
                  height: 128,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cats.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => CategoryChip(
                      category: cats[i],
                      onTap: () => context.push(
                        '/category/${cats[i].id}?name=${Uri.encodeComponent(cats[i].name)}',
                      ),
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
            _buildSection('Популярное', popularAsync),
            _buildSection('Новинки', newItemsAsync),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  Widget _buildSection(String title, AsyncValue<List<MenuItem>> asyncData) {
    return asyncData.when(
      data: (items) {
        if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 480,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => MenuItemCard(item: items[i]),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<dynamic>> results) {
    return results.when(
      data: (items) => items.isEmpty
          ? const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Text('Ничего не найдено',
                      style: TextStyle(color: AppColors.grey)),
                ),
              ),
            )
          : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => MenuItemCard(item: items[i]),
                  childCount: items.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
              ),
            ),
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Выйти?', style: TextStyle(color: AppColors.cream)),
        content: const Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: TextStyle(color: AppColors.greyLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final sm = ScaffoldMessenger.of(context);
              await ref.read(signOutProvider)();
              if (mounted) {
                nav.pop();
                sm.showSnackBar(
                  const SnackBar(content: Text('Вы вышли из системы')),
                );
              }
            },
            child: const Text('Выйти', style: TextStyle(color: AppColors.error)),
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
