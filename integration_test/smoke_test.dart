import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:plovxana/main.dart' as app;

void main() {
  patrolTest(
    'Splash screen: показывает название ресторана',
    ($) async {
      app.main();
      await $.pumpAndSettle();
      expect($('ПЛОВ НОМЕР 1'), findsOneWidget);
    },
  );

  patrolTest(
    'После splash: BottomNav показывает три вкладки',
    ($) async {
      app.main();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await $.pumpAndSettle();
      expect($(find.text('Меню')), findsOneWidget);
      expect($(find.text('Бронь')), findsOneWidget);
      expect($(find.text('Профиль')), findsOneWidget);
    },
  );

  patrolTest(
    'Переход на Бронь: открывается форма бронирования',
    ($) async {
      app.main();
      await $.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
      await $.pumpAndSettle();
      await $(find.text('Бронь')).tap();
      await $.pumpAndSettle();
      expect($(find.text('Бронирование стола')), findsOneWidget);
    },
  );
}
