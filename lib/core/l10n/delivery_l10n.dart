import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../config/app_config.dart';
import '../config/delivery_rules.dart';

extension DeliveryL10n on AppLocalizations {
  String shopClosedMessage() {
    final now = DateTime.now();
    final open = DateTime(now.year, now.month, now.day, AppConfig.shopOpenHour);
    if (now.isBefore(open)) return shopClosedOpensToday;
    return shopClosedAfterHours;
  }

  String? minOrderError(int subtotal, {required bool isDelivery}) {
    if (!isDelivery) return null;
    if (subtotal >= AppConfig.minDeliveryOrderAmount) return null;
    final diff = AppConfig.minDeliveryOrderAmount - subtotal;
    return minOrderErrorBody(
      formatTenge(AppConfig.minDeliveryOrderAmount),
      formatTenge(diff),
    );
  }

  String deliveryFeeShortLabel(int subtotal, {required bool isDelivery}) {
    if (!isDelivery) return deliveryFeeDash;
    final fee = deliveryFeeForSubtotal(subtotal, isDelivery: true);
    if (fee == 0) return deliveryFree;
    return deliveryFeeAmount(formatTenge(fee));
  }

  String deliveryBannerSummary() {
    return deliveryBannerBody(
      AppConfig.deliveryCity,
      formatTenge(AppConfig.deliveryFee),
      formatTenge(AppConfig.freeDeliveryThreshold),
      AppConfig.deliveryEtaMinMinutes,
      AppConfig.deliveryEtaMaxMinutes,
    );
  }

  String shopStatusClosingSoon() => shopStatusClosingSoonLabel;

  String shopStatusOpen() => shopStatusOpenLabel;

  String shopStatusClosed() => shopStatusClosedLabel;

  String orderStatusLabel(String status) => switch (status) {
        'confirmed' => orderStatusConfirmed,
        'done' => orderStatusDone,
        _ => orderStatusPending,
      };

  String cartDishCount(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 14) return cartDishesMany(count);
    if (mod10 == 1) return cartDishesOne(count);
    if (mod10 >= 2 && mod10 <= 4) return cartDishesFew(count);
    return cartDishesMany(count);
  }
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
