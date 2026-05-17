abstract class AppConfig {
  static const String whatsappNumber = String.fromEnvironment(
    'WHATSAPP_NUMBER',
    defaultValue: '77074007728',
  );

  static const String deliveryPhoneDisplay = '+7 707 400 77 28';

  static const int deliveryFee = 700;
  static const int freeDeliveryThreshold = 10000;
  static const int minDeliveryOrderAmount = 3000;
  static const int deliveryEtaMinMinutes = 45;
  static const int deliveryEtaMaxMinutes = 75;
  static const String deliveryCity = 'Павлодар';

  static const int shopOpenHour = 11;
  static const int shopLastOrderHour = 22;
  static const int shopLastOrderMinute = 45;

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static String get whatsappUrl => 'https://wa.me/$whatsappNumber';

  static const String restaurant2GISUrl =
      'https://2gis.kz/pavlodar/firm/70000001110142368';
}
