// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'ПЛОВ НОМЕР 1';

  @override
  String get navMenu => 'Мәзір';

  @override
  String get navReservation => 'Бронь';

  @override
  String get navProfile => 'Профиль';

  @override
  String get searchHint => 'Тағамдарды іздеу...';

  @override
  String get sectionPopular => 'Танымал';

  @override
  String get sectionNew => 'Жаңалықтар';

  @override
  String get sectionCategories => 'Санаттар';

  @override
  String get nothingFound => 'Ештеңе табылмады';

  @override
  String get offlineBanner => 'Интернет байланысы жоқ';

  @override
  String get offlineMenuCache => 'Интернет жоқ — соңғы мәзір көрсетіледі';

  @override
  String get logoutSuccess => 'Жүйеден шықтыңыз';

  @override
  String get logoutTitle => 'Шығу керек пе?';

  @override
  String get logoutMessage => 'Аккаунттан шығуға сенімдісіз бе?';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get logout => 'Шығу';

  @override
  String get aboutRestaurant => 'ПЛОВ НОМЕР 1';

  @override
  String get aboutAddress =>
      'Saida Plaza СО, Назарбаев даңғылы, 60/5, 1 қабат\n2GIS-те ашу үшін басыңыз';

  @override
  String get aboutHours => 'Күн сайын 11:00–24:00\nСоңғы тапсырыс: 22:45';

  @override
  String get aboutPhoneBooking => '+7 777 400 77 28 — бронь';

  @override
  String get aboutPhoneDelivery => '+7 707 400 77 28 — жеткізу';

  @override
  String get shopStatusOpenLabel => 'Қазір ашық';

  @override
  String get shopStatusClosingSoonLabel => 'Жақында жабылады';

  @override
  String get shopStatusClosedLabel => '11:00-де ашылады';

  @override
  String get shopClosedOpensToday => 'Мейрамхана бүгін 11:00-де ашылады';

  @override
  String get shopClosedAfterHours =>
      'Мейрамхана жабық. Соңғы тапсырыс 22:45-ке дейін.\nЕртең 11:00-ден келіңіз!';

  @override
  String minOrderErrorBody(String min, String diff) {
    return 'Жеткізудің минималды сомасы — $min тг. Тағы $diff тг қосыңыз';
  }

  @override
  String get deliveryFeeDash => '—';

  @override
  String get deliveryFree => 'Тегін';

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
    return '$city бойынша жеткізу · $fee тг · $threshold тг-ден тегін · $minMinutes–$maxMinutes мин';
  }

  @override
  String get deliverySheetTitle => 'Жеткізу шарттары';

  @override
  String get deliverySheetCostTitle => 'Құны';

  @override
  String deliverySheetCostBody(String fee, String threshold) {
    return '$fee тг. $threshold тг-ден жоғары тапсырысқа тегін.';
  }

  @override
  String get deliverySheetZoneTitle => 'Аймақ';

  @override
  String deliverySheetZoneBody(String city) {
    return 'Бүкіл $city бойынша жеткізу.';
  }

  @override
  String get deliverySheetTimeTitle => 'Уақыт';

  @override
  String deliverySheetTimeBody(int min, int max) {
    return 'Орташа $min–$max минут.';
  }

  @override
  String get deliverySheetPhoneTitle => 'Телефон';

  @override
  String get deliverySheetPaymentTitle => 'Төлем';

  @override
  String get deliverySheetPaymentBody => 'Қолма-қол немесе Kaspi аударымы.';

  @override
  String get cartTitle => 'Себет';

  @override
  String get cartClear => 'Тазалау';

  @override
  String get cartEmpty => 'Себет бос';

  @override
  String get cartGoToMenu => 'Мәзірге өту';

  @override
  String cartCheckout(String total) {
    return 'Рәсімдеу · $total тг';
  }

  @override
  String cartDishesOne(int count) {
    return '$count тағам';
  }

  @override
  String cartDishesFew(int count) {
    return '$count тағам';
  }

  @override
  String cartDishesMany(int count) {
    return '$count тағам';
  }

  @override
  String cartBarLabel(String dishes) {
    return 'Себет · $dishes';
  }

  @override
  String currencyTenge(String amount) {
    return '$amount тг';
  }

  @override
  String get checkoutTitle => 'Тапсырысты рәсімдеу';

  @override
  String get checkoutDeliveryType => 'Алу түрі';

  @override
  String get checkoutDelivery => 'Жеткізу';

  @override
  String get checkoutPickup => 'Алып кету';

  @override
  String get checkoutAddress => 'Жеткізу мекенжайы';

  @override
  String get checkoutAddressHint => 'Көше, үй, пәтер';

  @override
  String get checkoutContacts => 'Байланыс деректері';

  @override
  String get checkoutNameHint => 'Атыңыз';

  @override
  String get checkoutPhoneHint => '777 000 00 00';

  @override
  String get checkoutComment => 'Пікір';

  @override
  String get checkoutCommentHint => 'Тілектер, аллергия, ескертулер...';

  @override
  String get checkoutSubtotal => 'Тағамдар сомасы';

  @override
  String get checkoutDeliveryFee => 'Жеткізу';

  @override
  String get checkoutTotal => 'Барлығы';

  @override
  String get checkoutSubmit => 'WhatsApp-қа тапсырыс жіберу';

  @override
  String get checkoutSubmitHint => 'WhatsApp тапсырыспен ашылады';

  @override
  String get errorPhoneRequired => 'Телефон нөмірін көрсетіңіз';

  @override
  String get errorAddressRequired => 'Жеткізу мекенжайын көрсетіңіз';

  @override
  String get authTitle => 'Кіру';

  @override
  String get authPhoneTitle => 'Телефон нөмірін енгізіңіз';

  @override
  String get authOtpTitle => 'SMS кодын енгізіңіз';

  @override
  String get authPhoneSubtitle => 'Тапсырыс беру үшін авторизация қажет';

  @override
  String authOtpSubtitle(String phone) {
    return 'Код $phone нөміріне жіберілді';
  }

  @override
  String get authGetCode => 'Код алу';

  @override
  String get authConfirm => 'Растау';

  @override
  String get authChangePhone => 'Нөмірді өзгерту';

  @override
  String get authOtpHint => '000000';

  @override
  String get errorPhoneInvalid => 'Дұрыс телефон нөмірін енгізіңіз';

  @override
  String errorOtpSend(String error) {
    return 'Код жіберу қатесі: $error';
  }

  @override
  String get errorOtpInvalid => '6 таңбалы кодты енгізіңіз';

  @override
  String get errorOtpWrong => 'Қате код. Қайта көріңіз';

  @override
  String get orderSentTitle => 'Тапсырыс жіберілді!';

  @override
  String get orderSentBody =>
      'Тапсырысыңызды алдық, WhatsApp арқылы хабарласамыз';

  @override
  String get orderSentBack => 'Мәзірге оралу';

  @override
  String get reservationTitle => 'Үстел брондау';

  @override
  String get reservationDate => 'Күні';

  @override
  String get reservationTime => 'Уақыты';

  @override
  String get reservationGuests => 'Қонақтар';

  @override
  String get reservationName => 'Аты';

  @override
  String get reservationPhone => 'Телефон';

  @override
  String get reservationComment => 'Пікір';

  @override
  String get reservationChooseDateTime => 'Күн мен уақытты таңдаңыз';

  @override
  String get reservationGuestsLabel => 'Қонақтар саны';

  @override
  String get reservationCommentHint => 'Тілектер (бөлек зал, балалар орны...)';

  @override
  String get reservationSendWhatsapp => 'WhatsApp-қа брон жіберу';

  @override
  String get reservationPhoneConfirm => 'Растау телефон арқылы келеді';

  @override
  String get errorReservationContacts => 'Атыңыз бен телефонды көрсетіңіз';

  @override
  String get selectRequiredModifiers => 'Міндетті опцияларды таңдаңыз';

  @override
  String itemQuantityLine(int qty, String total) {
    return '$qty дана · $total тг';
  }

  @override
  String get orderSentBodyLong =>
      'Тапсырысыңыз WhatsApp арқылы жіберілді. Оператор растауын күтіңіз.';

  @override
  String get reservationSubmit => 'Үстелді брондау';

  @override
  String get reservationSuccess => 'Брондау сұрауы жіберілді!';

  @override
  String get errorNameRequired => 'Атыңызды көрсетіңіз';

  @override
  String get errorGuestsRequired => 'Қонақтар санын көрсетіңіз';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profilePhone => 'Телефон';

  @override
  String get profilePhoneMissing => 'Көрсетілмеген';

  @override
  String get profileLastAddress => 'Соңғы жеткізу мекенжайы';

  @override
  String get profileOrders => 'Тапсырыс тарихы';

  @override
  String get profileLogout => 'Аккаунттан шығу';

  @override
  String get profileLanguage => 'Тіл';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageKk => 'Қазақша';

  @override
  String get ordersTitle => 'Менің тапсырыстарым';

  @override
  String get ordersEmpty => 'Тапсырыс жоқ';

  @override
  String get ordersEmptyHint => 'Тапсырыстарыңыз осында көрінеді';

  @override
  String ordersError(String error) {
    return 'Қате: $error';
  }

  @override
  String ordersMoreItems(int count) {
    return '+ тағы $count поз.';
  }

  @override
  String get orderStatusPending => 'Қабылданды';

  @override
  String get orderStatusConfirmed => 'Расталды';

  @override
  String get orderStatusDone => 'Орындалды';

  @override
  String get itemNotFound => 'Тағам табылмады';

  @override
  String get loadError => 'Жүктеу қатесі';

  @override
  String get addToCart => 'Себетке қосу';

  @override
  String get halal => 'Халал';

  @override
  String get spicy => 'Ащы';

  @override
  String weightGrams(int weight) {
    return '$weight г';
  }

  @override
  String get pushOrderConfirmedTitle => 'Тапсырыс расталды';

  @override
  String get pushOrderConfirmedBody => 'Мейрамхана тапсырысыңызды қабылдады';

  @override
  String get pushOrderDoneTitle => 'Тапсырыс орындалды';

  @override
  String get pushOrderDoneBody => 'Ас болсын!';
}
