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
import '../../../../shared/widgets/ikat_pattern_background.dart';
import '../../../../shared/widgets/ornamental_divider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/delivery_l10n.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final scrolled = _scrollCtrl.offset > 0;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final popularAsync = ref.watch(popularItemsProvider);
    final newItemsAsync = ref.watch(newItemsProvider);
    final promotionsAsync = ref.watch(promotionsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchProvider);

    final l10n = context.l10n;
    final isLoading = categoriesAsync.isLoading || popularAsync.isLoading;

    if (isLoading && searchQuery.isEmpty) {
      return const Scaffold(body: SafeArea(child: MenuShimmer()));
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 72,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 0.5,
                color: _scrolled ? AppColors.divider : Colors.transparent,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
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
                onChanged: (v) {
                  ref.read(searchQueryProvider.notifier).state = v;
                  ref.read(searchProvider.notifier).search(v);
                },
                style: const TextStyle(color: AppColors.cream),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
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
          if (categoriesAsync.hasError)
            const SliverToBoxAdapter(child: _OfflineBanner()),
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
            _buildSectionTitle(l10n.sectionCategories),
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
            _buildSection(l10n.sectionPopular, popularAsync),
            _buildSection(l10n.sectionNew, newItemsAsync),
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
        child: _sectionTitle(title),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 12),
        const Expanded(child: OrnamentalDivider()),
      ],
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
                child: _sectionTitle(title),
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
    final l10n = context.l10n;
    return results.when(
      data: (items) => items.isEmpty
          ? SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(l10n.nothingFound,
                      style: const TextStyle(color: AppColors.grey)),
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

  void _showInfo(BuildContext context) {
    final l10n = context.l10n;
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
              l10n.aboutRestaurant,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(AppConfig.restaurant2GISUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: _infoRow(
                Icons.location_on_outlined,
                l10n.aboutAddress,
                valueColor: AppColors.accentBlue,
              ),
            ),
            _infoRow(Icons.access_time_outlined, l10n.aboutHours),
            _infoRow(Icons.phone_outlined, l10n.aboutPhoneBooking),
            _infoRow(Icons.delivery_dining_outlined, l10n.aboutPhoneDelivery),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: valueColor ?? AppColors.cream,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineMenuCache,
              style: const TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
