import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/delivery_rules.dart';
import '../../core/l10n/delivery_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../features/cart/data/cart_provider.dart';

class FloatingCartBar extends ConsumerWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: count == 0
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () => context.push('/cart'),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.cartBarLabel(l10n.cartDishCount(count)),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.currencyTenge(formatTenge(total)),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.background,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
