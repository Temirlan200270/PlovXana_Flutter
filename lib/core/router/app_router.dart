import 'package:go_router/go_router.dart';
import '../../features/menu/presentation/screens/home_screen.dart';
import '../../features/menu/presentation/screens/category_screen.dart';
import '../../features/menu/presentation/screens/item_detail_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_sent_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/reservation/presentation/reservation_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/models/menu_item.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
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
      ],
    ),
    GoRoute(
      path: '/item/:id',
      builder: (c, s) {
        final item = s.extra as MenuItem;
        return ItemDetailScreen(item: item);
      },
    ),
    GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (c, s) => const CheckoutScreen()),
    GoRoute(path: '/order-sent', builder: (c, s) => const OrderSentScreen()),
    GoRoute(path: '/auth', builder: (c, s) => const AuthScreen()),
  ],
);
