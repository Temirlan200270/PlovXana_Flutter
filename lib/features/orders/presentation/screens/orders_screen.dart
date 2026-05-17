import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/delivery_l10n.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/config/delivery_rules.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/order.dart';
import '../../data/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.ordersEmpty,
                    style: const TextStyle(
                        color: AppColors.greyLight, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.ordersEmptyHint,
                    style: const TextStyle(
                        color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            l10n.ordersError('$e'),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final localeCode = ref.watch(localeProvider).languageCode;
    final date = DateFormat('d MMMM, HH:mm', localeCode)
        .format(order.createdAt.toLocal());
    final isDelivery = order.deliveryType == 'delivery';
    final items = order.itemsJson;
    final statusLabel = l10n.orderStatusLabel(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: const TextStyle(
                      color: AppColors.greyLight, fontSize: 12)),
              _StatusChip(status: statusLabel),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${item['name']} × ${item['quantity']}',
                  style: const TextStyle(
                      color: AppColors.cream, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
          if (items.length > 3)
            Text(
              l10n.ordersMoreItems(items.length - 3),
              style: const TextStyle(
                  color: AppColors.greyLight, fontSize: 12),
            ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDelivery
                        ? Icons.delivery_dining_outlined
                        : Icons.storefront_outlined,
                    size: 16,
                    color: AppColors.greyLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDelivery ? l10n.checkoutDelivery : l10n.checkoutPickup,
                    style: const TextStyle(
                        color: AppColors.greyLight, fontSize: 12),
                  ),
                ],
              ),
              Text(
                l10n.currencyTenge(formatTenge(order.total)),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = status == l10n.orderStatusDone
        ? AppColors.halal
        : status == l10n.orderStatusConfirmed
            ? AppColors.primary
            : AppColors.greyLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
