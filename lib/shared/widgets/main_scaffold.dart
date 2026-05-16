import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'floating_cart_bar.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/reservation')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FloatingCartBar(),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (i) {
                  if (i == 0) context.go('/');
                  if (i == 1) context.go('/reservation');
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu_outlined),
                    activeIcon: Icon(Icons.restaurant_menu),
                    label: 'Меню',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_seat_outlined),
                    activeIcon: Icon(Icons.event_seat),
                    label: 'Бронь',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
