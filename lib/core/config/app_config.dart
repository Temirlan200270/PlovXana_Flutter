abstract class AppConfig {
  static const String whatsappNumber = String.fromEnvironment(
    'WHATSAPP_NUMBER',
    defaultValue: '77074007728',
  );

  static String get whatsappUrl => 'https://wa.me/$whatsappNumber';
}
