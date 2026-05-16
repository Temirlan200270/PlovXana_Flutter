import 'app_config.dart';

// ─── Shop hours ───────────────────────────────────────────────────────────────

bool isShopOpen() {
  final now = DateTime.now();
  final open = DateTime(now.year, now.month, now.day, AppConfig.shopOpenHour);
  final lastOrder = DateTime(
    now.year, now.month, now.day,
    AppConfig.shopLastOrderHour, AppConfig.shopLastOrderMinute,
  );
  return now.isAfter(open) && now.isBefore(lastOrder);
}

bool isClosingSoon() {
  final now = DateTime.now();
  final lastOrder = DateTime(
    now.year, now.month, now.day,
    AppConfig.shopLastOrderHour, AppConfig.shopLastOrderMinute,
  );
  final warnFrom = lastOrder.subtract(const Duration(minutes: 30));
  return now.isAfter(warnFrom) && now.isBefore(lastOrder);
}

// ─── Delivery fee ─────────────────────────────────────────────────────────────

int deliveryFeeForSubtotal(int subtotal, {required bool isDelivery}) {
  if (!isDelivery) return 0;
  if (subtotal >= AppConfig.freeDeliveryThreshold) return 0;
  return AppConfig.deliveryFee;
}

int orderGrandTotal(int subtotal, int deliveryFee) => subtotal + deliveryFee;

String formatTenge(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]} ',
  );
}

