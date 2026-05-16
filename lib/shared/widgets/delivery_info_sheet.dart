import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/config/delivery_rules.dart';
import '../../core/theme/app_colors.dart';

void showDeliveryInfoSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const DeliveryInfoSheet(),
  );
}

class DeliveryInfoSheet extends StatelessWidget {
  const DeliveryInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Условия доставки',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          _row(
            Icons.payments_outlined,
            'Стоимость',
            '${formatTenge(AppConfig.deliveryFee)} тг. '
            'Бесплатно при заказе от ${formatTenge(AppConfig.freeDeliveryThreshold)} тг.',
          ),
          _row(
            Icons.location_on_outlined,
            'Зона',
            'Доставка по всему ${AppConfig.deliveryCity}.',
          ),
          _row(
            Icons.schedule_outlined,
            'Время',
            'В среднем ${AppConfig.deliveryEtaMinMinutes}–'
            '${AppConfig.deliveryEtaMaxMinutes} минут.',
          ),
          _row(
            Icons.phone_outlined,
            'Телефон',
            AppConfig.deliveryPhoneDisplay,
          ),
          _row(
            Icons.account_balance_wallet_outlined,
            'Оплата',
            'Наличные или Kaspi перевод при получении.',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.greyLight,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
