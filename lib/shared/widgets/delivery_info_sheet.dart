import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/config/delivery_rules.dart';
import '../../core/l10n/delivery_l10n.dart';
import '../../core/theme/app_colors.dart';

void showDeliveryInfoSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DeliveryInfoSheet(parentContext: context),
  );
}

class DeliveryInfoSheet extends StatelessWidget {
  const DeliveryInfoSheet({super.key, required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final l10n = parentContext.l10n;

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
            l10n.deliverySheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          _row(
            Icons.payments_outlined,
            l10n.deliverySheetCostTitle,
            l10n.deliverySheetCostBody(
              formatTenge(AppConfig.deliveryFee),
              formatTenge(AppConfig.freeDeliveryThreshold),
            ),
          ),
          _row(
            Icons.location_on_outlined,
            l10n.deliverySheetZoneTitle,
            l10n.deliverySheetZoneBody(AppConfig.deliveryCity),
          ),
          _row(
            Icons.schedule_outlined,
            l10n.deliverySheetTimeTitle,
            l10n.deliverySheetTimeBody(
              AppConfig.deliveryEtaMinMinutes,
              AppConfig.deliveryEtaMaxMinutes,
            ),
          ),
          _row(
            Icons.phone_outlined,
            l10n.deliverySheetPhoneTitle,
            AppConfig.deliveryPhoneDisplay,
          ),
          _row(
            Icons.account_balance_wallet_outlined,
            l10n.deliverySheetPaymentTitle,
            l10n.deliverySheetPaymentBody,
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
