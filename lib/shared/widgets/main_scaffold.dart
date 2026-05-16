import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/delivery_l10n.dart';
import '../../core/theme/app_colors.dart';
import 'floating_cart_bar.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/reservation')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
                  if (i == 2) context.go('/profile');
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.restaurant_menu_outlined),
                    activeIcon: const Icon(Icons.restaurant_menu),
                    label: l10n.navMenu,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.event_seat_outlined),
                    activeIcon: const Icon(Icons.event_seat),
                    label: l10n.navReservation,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(Icons.person),
                    label: l10n.navProfile,
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
