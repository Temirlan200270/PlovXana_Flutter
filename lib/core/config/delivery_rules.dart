import 'app_config.dart';

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

String deliveryFeeShortLabel(int subtotal, {required bool isDelivery}) {
  if (!isDelivery) return '—';
  final fee = deliveryFeeForSubtotal(subtotal, isDelivery: true);
  if (fee == 0) return 'Бесплатно';
  return '${formatTenge(fee)} тг';
}

String deliveryBannerSummary() {
  return 'Доставка по ${AppConfig.deliveryCity} · '
      '${formatTenge(AppConfig.deliveryFee)} тг · '
      'бесплатно от ${formatTenge(AppConfig.freeDeliveryThreshold)} тг · '
      '${AppConfig.deliveryEtaMinMinutes}–${AppConfig.deliveryEtaMaxMinutes} мин';
}
