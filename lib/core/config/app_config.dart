abstract class AppConfig {
  static const String whatsappNumber = String.fromEnvironment(
    'WHATSAPP_NUMBER',
    defaultValue: '77074007728',
  );

  static const String deliveryPhoneDisplay = '+7 707 400 77 28';

  static const int deliveryFee = 700;
  static const int freeDeliveryThreshold = 10000;
  static const int deliveryEtaMinMinutes = 45;
  static const int deliveryEtaMaxMinutes = 75;
  static const String deliveryCity = 'Павлодар';

  static String get whatsappUrl => 'https://wa.me/$whatsappNumber';
}
