import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/menu/presentation/screens/home_screen.dart';
import '../../features/menu/presentation/screens/category_screen.dart';
import '../../features/menu/presentation/screens/item_detail_screen.dart';
import '../../features/menu/data/menu_providers.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_sent_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/reservation/presentation/reservation_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/models/menu_item.dart';
import '../../core/l10n/delivery_l10n.dart';
import '../../core/theme/app_colors.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(
          path: '/category/:id',
          builder: (c, s) => CategoryScreen(
            categoryId: s.pathParameters['id']!,
            categoryName: s.uri.queryParameters['name'] ?? '',
          ),
        ),
        GoRoute(path: '/reservation', builder: (c, s) => const ReservationScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/item/:id',
      builder: (c, s) {
        final item = s.extra as MenuItem?;
        final id = s.pathParameters['id']!;
        if (item != null) return ItemDetailScreen(item: item);
        return _ItemDetailByIdLoader(itemId: id);
      },
    ),
    GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen()),
    GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (c, s) => const CheckoutScreen()),
    GoRoute(path: '/order-sent', builder: (c, s) => const OrderSentScreen()),
    GoRoute(path: '/auth', builder: (c, s) => const AuthScreen()),
  ],
);

class _ItemDetailByIdLoader extends ConsumerWidget {
  final String itemId;
  const _ItemDetailByIdLoader({required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(menuItemByIdProvider(itemId));
    final l10n = context.l10n;
    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(l10n.itemNotFound,
                  style: const TextStyle(color: AppColors.greyLight)),
            ),
          );
        }
        return ItemDetailScreen(item: item);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(l10n.loadError,
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}
