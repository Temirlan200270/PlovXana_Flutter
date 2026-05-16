import 'package:flutter/material.dart';
import '../../core/config/delivery_rules.dart';
import '../../core/theme/app_colors.dart';
import 'delivery_info_sheet.dart';

class DeliveryInfoBanner extends StatelessWidget {
  const DeliveryInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => showDeliveryInfoSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentBlue.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.accentBlue.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    deliveryBannerSummary(),
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.greyLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
