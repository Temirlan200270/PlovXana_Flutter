// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'PlovХана';

  @override
  String get navMenu => 'Меню';

  @override
  String get navReservation => 'Бронь';

  @override
  String get navProfile => 'Профиль';

  @override
  String get searchHint => 'Поиск блюд...';

  @override
  String get sectionPopular => 'Популярное';

  @override
  String get sectionNew => 'Новинки';

  @override
  String get sectionCategories => 'Категории';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get offlineBanner => 'Нет подключения к интернету';

  @override
  String get offlineMenuCache => 'Нет интернета — показываем последнее меню';

  @override
  String get logoutSuccess => 'Вы вышли из системы';

  @override
  String get logoutTitle => 'Выйти?';

  @override
  String get logoutMessage => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get cancel => 'Отмена';

  @override
  String get logout => 'Выйти';

  @override
  String get aboutRestaurant => 'PlovХана';

  @override
  String get aboutAddress =>
      'ТЦ Saida Plaza, пр. Нурсултана Назарбаева, 60/5, 1 этаж\nНажмите, чтобы открыть в 2GIS';

  @override
  String get aboutHours => 'Ежедневно 11:00–24:00\nПоследний заказ: 22:45';

  @override
  String get aboutPhoneBooking => '+7 777 400 77 28 — бронирование';

  @override
  String get aboutPhoneDelivery => '+7 707 400 77 28 — доставка';

  @override
  String get shopStatusOpenLabel => 'Сейчас открыто';

  @override
  String get shopStatusClosingSoonLabel => 'Закроется скоро';

  @override
  String get shopStatusClosedLabel => 'Закрыто до 11:00';

  @override
  String get shopClosedOpensToday => 'Ресторан откроется сегодня в 11:00';

  @override
  String get shopClosedAfterHours =>
      'Ресторан закрыт. Последний заказ до 22:45.\nПриходите завтра с 11:00!';

  @override
  String minOrderErrorBody(String min, String diff) {
    return 'Минимальная сумма доставки — $min тг. Добавьте блюд ещё на $diff тг';
  }

  @override
  String get deliveryFeeDash => '—';

  @override
  String get deliveryFree => 'Бесплатно';

  @override
  String deliveryFeeAmount(String amount) {
    return '$amount тг';
  }

  @override
  String deliveryBannerBody(
    String city,
    String fee,
    String threshold,
    int minMinutes,
    int maxMinutes,
  ) {
    return 'Доставка по $city · $fee тг · бесплатно от $threshold тг · $minMinutes–$maxMinutes мин';
  }

  @override
  String get deliverySheetTitle => 'Условия доставки';

  @override
  String get deliverySheetCostTitle => 'Стоимость';

  @override
  String deliverySheetCostBody(String fee, String threshold) {
    return '$fee тг. Бесплатно при заказе от $threshold тг.';
  }

  @override
  String get deliverySheetZoneTitle => 'Зона';

  @override
  String deliverySheetZoneBody(String city) {
    return 'Доставка по всему $city.';
  }

  @override
  String get deliverySheetTimeTitle => 'Время';

  @override
  String deliverySheetTimeBody(int min, int max) {
    return 'В среднем $min–$max минут.';
  }

  @override
  String get deliverySheetPhoneTitle => 'Телефон';

  @override
  String get deliverySheetPaymentTitle => 'Оплата';

  @override
  String get deliverySheetPaymentBody =>
      'Наличные или Kaspi перевод при получении.';

  @override
  String get cartTitle => 'Корзина';

  @override
  String get cartClear => 'Очистить';

  @override
  String get cartEmpty => 'Корзина пуста';

  @override
  String get cartGoToMenu => 'Перейти в меню';

  @override
  String cartCheckout(String total) {
    return 'Оформить · $total тг';
  }

  @override
  String cartDishesOne(int count) {
    return '$count блюдо';
  }

  @override
  String cartDishesFew(int count) {
    return '$count блюда';
  }

  @override
  String cartDishesMany(int count) {
    return '$count блюд';
  }

  @override
  String cartBarLabel(String dishes) {
    return 'Корзина · $dishes';
  }

  @override
  String currencyTenge(String amount) {
    return '$amount тг';
  }

  @override
  String get checkoutTitle => 'Оформление заказа';

  @override
  String get checkoutDeliveryType => 'Тип получения';

  @override
  String get checkoutDelivery => 'Доставка';

  @override
  String get checkoutPickup => 'Самовывоз';

  @override
  String get checkoutAddress => 'Адрес доставки';

  @override
  String get checkoutAddressHint => 'Улица, дом, квартира';

  @override
  String get checkoutContacts => 'Контактные данные';

  @override
  String get checkoutNameHint => 'Ваше имя';

  @override
  String get checkoutPhoneHint => '777 000 00 00';

  @override
  String get checkoutComment => 'Комментарий';

  @override
  String get checkoutCommentHint => 'Пожелания, аллергии, уточнения...';

  @override
  String get checkoutSubtotal => 'Сумма блюд';

  @override
  String get checkoutDeliveryFee => 'Доставка';

  @override
  String get checkoutTotal => 'Итого';

  @override
  String get checkoutSubmit => 'Отправить заказ в WhatsApp';

  @override
  String get checkoutSubmitHint => 'Откроется WhatsApp с вашим заказом';

  @override
  String get errorPhoneRequired => 'Укажите номер телефона';

  @override
  String get errorAddressRequired => 'Укажите адрес доставки';

  @override
  String get authTitle => 'Вход';

  @override
  String get authPhoneTitle => 'Введите номер телефона';

  @override
  String get authOtpTitle => 'Введите код из СМС';

  @override
  String get authPhoneSubtitle => 'Для оформления заказа нужна авторизация';

  @override
  String authOtpSubtitle(String phone) {
    return 'Мы отправили код на $phone';
  }

  @override
  String get authGetCode => 'Получить код';

  @override
  String get authConfirm => 'Подтвердить';

  @override
  String get authChangePhone => 'Изменить номер';

  @override
  String get authOtpHint => '000000';

  @override
  String get errorPhoneInvalid => 'Введите корректный номер телефона';

  @override
  String errorOtpSend(String error) {
    return 'Ошибка отправки кода: $error';
  }

  @override
  String get errorOtpInvalid => 'Введите 6-значный код';

  @override
  String get errorOtpWrong => 'Неверный код. Попробуйте ещё раз';

  @override
  String get orderSentTitle => 'Заказ отправлен!';

  @override
  String get orderSentBody =>
      'Мы получили ваш заказ и свяжемся с вами в WhatsApp';

  @override
  String get orderSentBack => 'Вернуться в меню';

  @override
  String get reservationTitle => 'Бронирование стола';

  @override
  String get reservationDate => 'Дата';

  @override
  String get reservationTime => 'Время';

  @override
  String get reservationGuests => 'Гостей';

  @override
  String get reservationName => 'Имя';

  @override
  String get reservationPhone => 'Телефон';

  @override
  String get reservationComment => 'Комментарий';

  @override
  String get reservationChooseDateTime => 'Выберите дату и время';

  @override
  String get reservationGuestsLabel => 'Количество гостей';

  @override
  String get reservationCommentHint =>
      'Пожелания (отдельный зал, детское место...)';

  @override
  String get reservationSendWhatsapp => 'Отправить бронь в WhatsApp';

  @override
  String get reservationPhoneConfirm => 'Подтверждение придёт по телефону';

  @override
  String get errorReservationContacts => 'Укажите имя и телефон';

  @override
  String get selectRequiredModifiers => 'Выберите обязательные опции';

  @override
  String itemQuantityLine(int qty, String total) {
    return '$qty шт · $total тг';
  }

  @override
  String get orderSentBodyLong =>
      'Ваш заказ отправлен в WhatsApp ресторана. Ожидайте подтверждения от оператора.';

  @override
  String get reservationSubmit => 'Забронировать стол';

  @override
  String get reservationSuccess => 'Запрос на бронирование отправлен!';

  @override
  String get errorNameRequired => 'Укажите имя';

  @override
  String get errorGuestsRequired => 'Укажите количество гостей';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profilePhone => 'Телефон';

  @override
  String get profilePhoneMissing => 'Не указан';

  @override
  String get profileLastAddress => 'Последний адрес доставки';

  @override
  String get profileOrders => 'История заказов';

  @override
  String get profileLogout => 'Выйти из аккаунта';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageKk => 'Қазақша';

  @override
  String get ordersTitle => 'Мои заказы';

  @override
  String get ordersEmpty => 'Заказов пока нет';

  @override
  String get ordersEmptyHint => 'Ваши заказы появятся здесь';

  @override
  String ordersError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String ordersMoreItems(int count) {
    return '+ ещё $count позиц.';
  }

  @override
  String get orderStatusPending => 'Принят';

  @override
  String get orderStatusConfirmed => 'Подтверждён';

  @override
  String get orderStatusDone => 'Выполнен';

  @override
  String get itemNotFound => 'Блюдо не найдено';

  @override
  String get loadError => 'Ошибка загрузки';

  @override
  String get addToCart => 'Добавить в корзину';

  @override
  String get halal => 'Халяль';

  @override
  String get spicy => 'Острое';

  @override
  String weightGrams(int weight) {
    return '$weight г';
  }

  @override
  String get pushOrderConfirmedTitle => 'Заказ подтверждён';

  @override
  String get pushOrderConfirmedBody => 'Ресторан принял ваш заказ';

  @override
  String get pushOrderDoneTitle => 'Заказ выполнен';

  @override
  String get pushOrderDoneBody => 'Приятного аппетита!';
}
