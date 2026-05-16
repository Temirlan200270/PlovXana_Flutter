import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'ПЛОВ НОМЕР 1'**
  String get appTitle;

  /// No description provided for @navMenu.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get navMenu;

  /// No description provided for @navReservation.
  ///
  /// In ru, this message translates to:
  /// **'Бронь'**
  String get navReservation;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск блюд...'**
  String get searchHint;

  /// No description provided for @sectionPopular.
  ///
  /// In ru, this message translates to:
  /// **'Популярное'**
  String get sectionPopular;

  /// No description provided for @sectionNew.
  ///
  /// In ru, this message translates to:
  /// **'Новинки'**
  String get sectionNew;

  /// No description provided for @sectionCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get sectionCategories;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @offlineBanner.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к интернету'**
  String get offlineBanner;

  /// No description provided for @offlineMenuCache.
  ///
  /// In ru, this message translates to:
  /// **'Нет интернета — показываем последнее меню'**
  String get offlineMenuCache;

  /// No description provided for @logoutSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Вы вышли из системы'**
  String get logoutSuccess;

  /// No description provided for @logoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти из аккаунта?'**
  String get logoutMessage;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @aboutRestaurant.
  ///
  /// In ru, this message translates to:
  /// **'ПЛОВ НОМЕР 1'**
  String get aboutRestaurant;

  /// No description provided for @aboutAddress.
  ///
  /// In ru, this message translates to:
  /// **'ТЦ Saida Plaza, пр. Нурсултана Назарбаева, 60/5, 1 этаж\nНажмите, чтобы открыть в 2GIS'**
  String get aboutAddress;

  /// No description provided for @aboutHours.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневно 11:00–24:00\nПоследний заказ: 22:45'**
  String get aboutHours;

  /// No description provided for @aboutPhoneBooking.
  ///
  /// In ru, this message translates to:
  /// **'+7 777 400 77 28 — бронирование'**
  String get aboutPhoneBooking;

  /// No description provided for @aboutPhoneDelivery.
  ///
  /// In ru, this message translates to:
  /// **'+7 707 400 77 28 — доставка'**
  String get aboutPhoneDelivery;

  /// No description provided for @shopStatusOpenLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас открыто'**
  String get shopStatusOpenLabel;

  /// No description provided for @shopStatusClosingSoonLabel.
  ///
  /// In ru, this message translates to:
  /// **'Закроется скоро'**
  String get shopStatusClosingSoonLabel;

  /// No description provided for @shopStatusClosedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Закрыто до 11:00'**
  String get shopStatusClosedLabel;

  /// No description provided for @shopClosedOpensToday.
  ///
  /// In ru, this message translates to:
  /// **'Ресторан откроется сегодня в 11:00'**
  String get shopClosedOpensToday;

  /// No description provided for @shopClosedAfterHours.
  ///
  /// In ru, this message translates to:
  /// **'Ресторан закрыт. Последний заказ до 22:45.\nПриходите завтра с 11:00!'**
  String get shopClosedAfterHours;

  /// No description provided for @minOrderErrorBody.
  ///
  /// In ru, this message translates to:
  /// **'Минимальная сумма доставки — {min} тг. Добавьте блюд ещё на {diff} тг'**
  String minOrderErrorBody(String min, String diff);

  /// No description provided for @deliveryFeeDash.
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get deliveryFeeDash;

  /// No description provided for @deliveryFree.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатно'**
  String get deliveryFree;

  /// No description provided for @deliveryFeeAmount.
  ///
  /// In ru, this message translates to:
  /// **'{amount} тг'**
  String deliveryFeeAmount(String amount);

  /// No description provided for @deliveryBannerBody.
  ///
  /// In ru, this message translates to:
  /// **'Доставка по {city} · {fee} тг · бесплатно от {threshold} тг · {minMinutes}–{maxMinutes} мин'**
  String deliveryBannerBody(
    String city,
    String fee,
    String threshold,
    int minMinutes,
    int maxMinutes,
  );

  /// No description provided for @deliverySheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Условия доставки'**
  String get deliverySheetTitle;

  /// No description provided for @deliverySheetCostTitle.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость'**
  String get deliverySheetCostTitle;

  /// No description provided for @deliverySheetCostBody.
  ///
  /// In ru, this message translates to:
  /// **'{fee} тг. Бесплатно при заказе от {threshold} тг.'**
  String deliverySheetCostBody(String fee, String threshold);

  /// No description provided for @deliverySheetZoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Зона'**
  String get deliverySheetZoneTitle;

  /// No description provided for @deliverySheetZoneBody.
  ///
  /// In ru, this message translates to:
  /// **'Доставка по всему {city}.'**
  String deliverySheetZoneBody(String city);

  /// No description provided for @deliverySheetTimeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get deliverySheetTimeTitle;

  /// No description provided for @deliverySheetTimeBody.
  ///
  /// In ru, this message translates to:
  /// **'В среднем {min}–{max} минут.'**
  String deliverySheetTimeBody(int min, int max);

  /// No description provided for @deliverySheetPhoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get deliverySheetPhoneTitle;

  /// No description provided for @deliverySheetPaymentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get deliverySheetPaymentTitle;

  /// No description provided for @deliverySheetPaymentBody.
  ///
  /// In ru, this message translates to:
  /// **'Наличные или Kaspi перевод при получении.'**
  String get deliverySheetPaymentBody;

  /// No description provided for @cartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Корзина'**
  String get cartTitle;

  /// No description provided for @cartClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get cartClear;

  /// No description provided for @cartEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Корзина пуста'**
  String get cartEmpty;

  /// No description provided for @cartGoToMenu.
  ///
  /// In ru, this message translates to:
  /// **'Перейти в меню'**
  String get cartGoToMenu;

  /// No description provided for @cartCheckout.
  ///
  /// In ru, this message translates to:
  /// **'Оформить · {total} тг'**
  String cartCheckout(String total);

  /// No description provided for @cartDishesOne.
  ///
  /// In ru, this message translates to:
  /// **'{count} блюдо'**
  String cartDishesOne(int count);

  /// No description provided for @cartDishesFew.
  ///
  /// In ru, this message translates to:
  /// **'{count} блюда'**
  String cartDishesFew(int count);

  /// No description provided for @cartDishesMany.
  ///
  /// In ru, this message translates to:
  /// **'{count} блюд'**
  String cartDishesMany(int count);

  /// No description provided for @cartBarLabel.
  ///
  /// In ru, this message translates to:
  /// **'Корзина · {dishes}'**
  String cartBarLabel(String dishes);

  /// No description provided for @currencyTenge.
  ///
  /// In ru, this message translates to:
  /// **'{amount} тг'**
  String currencyTenge(String amount);

  /// No description provided for @checkoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оформление заказа'**
  String get checkoutTitle;

  /// No description provided for @checkoutDeliveryType.
  ///
  /// In ru, this message translates to:
  /// **'Тип получения'**
  String get checkoutDeliveryType;

  /// No description provided for @checkoutDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get checkoutDelivery;

  /// No description provided for @checkoutPickup.
  ///
  /// In ru, this message translates to:
  /// **'Самовывоз'**
  String get checkoutPickup;

  /// No description provided for @checkoutAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес доставки'**
  String get checkoutAddress;

  /// No description provided for @checkoutAddressHint.
  ///
  /// In ru, this message translates to:
  /// **'Улица, дом, квартира'**
  String get checkoutAddressHint;

  /// No description provided for @checkoutContacts.
  ///
  /// In ru, this message translates to:
  /// **'Контактные данные'**
  String get checkoutContacts;

  /// No description provided for @checkoutNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get checkoutNameHint;

  /// No description provided for @checkoutPhoneHint.
  ///
  /// In ru, this message translates to:
  /// **'777 000 00 00'**
  String get checkoutPhoneHint;

  /// No description provided for @checkoutComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get checkoutComment;

  /// No description provided for @checkoutCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'Пожелания, аллергии, уточнения...'**
  String get checkoutCommentHint;

  /// No description provided for @checkoutSubtotal.
  ///
  /// In ru, this message translates to:
  /// **'Сумма блюд'**
  String get checkoutSubtotal;

  /// No description provided for @checkoutDeliveryFee.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get checkoutDeliveryFee;

  /// No description provided for @checkoutTotal.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get checkoutTotal;

  /// No description provided for @checkoutSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Отправить заказ в WhatsApp'**
  String get checkoutSubmit;

  /// No description provided for @checkoutSubmitHint.
  ///
  /// In ru, this message translates to:
  /// **'Откроется WhatsApp с вашим заказом'**
  String get checkoutSubmitHint;

  /// No description provided for @errorPhoneRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите номер телефона'**
  String get errorPhoneRequired;

  /// No description provided for @errorAddressRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите адрес доставки'**
  String get errorAddressRequired;

  /// No description provided for @authTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get authTitle;

  /// No description provided for @authPhoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона'**
  String get authPhoneTitle;

  /// No description provided for @authOtpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите код из СМС'**
  String get authOtpTitle;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Для оформления заказа нужна авторизация'**
  String get authPhoneSubtitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправили код на {phone}'**
  String authOtpSubtitle(String phone);

  /// No description provided for @authGetCode.
  ///
  /// In ru, this message translates to:
  /// **'Получить код'**
  String get authGetCode;

  /// No description provided for @authConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get authConfirm;

  /// No description provided for @authChangePhone.
  ///
  /// In ru, this message translates to:
  /// **'Изменить номер'**
  String get authChangePhone;

  /// No description provided for @authOtpHint.
  ///
  /// In ru, this message translates to:
  /// **'000000'**
  String get authOtpHint;

  /// No description provided for @errorPhoneInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный номер телефона'**
  String get errorPhoneInvalid;

  /// No description provided for @errorOtpSend.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка отправки кода: {error}'**
  String errorOtpSend(String error);

  /// No description provided for @errorOtpInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите 6-значный код'**
  String get errorOtpInvalid;

  /// No description provided for @errorOtpWrong.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код. Попробуйте ещё раз'**
  String get errorOtpWrong;

  /// No description provided for @orderSentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ отправлен!'**
  String get orderSentTitle;

  /// No description provided for @orderSentBody.
  ///
  /// In ru, this message translates to:
  /// **'Мы получили ваш заказ и свяжемся с вами в WhatsApp'**
  String get orderSentBody;

  /// No description provided for @orderSentBack.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться в меню'**
  String get orderSentBack;

  /// No description provided for @reservationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование стола'**
  String get reservationTitle;

  /// No description provided for @reservationDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get reservationDate;

  /// No description provided for @reservationTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get reservationTime;

  /// No description provided for @reservationGuests.
  ///
  /// In ru, this message translates to:
  /// **'Гостей'**
  String get reservationGuests;

  /// No description provided for @reservationName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get reservationName;

  /// No description provided for @reservationPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get reservationPhone;

  /// No description provided for @reservationComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get reservationComment;

  /// No description provided for @reservationChooseDateTime.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату и время'**
  String get reservationChooseDateTime;

  /// No description provided for @reservationGuestsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Количество гостей'**
  String get reservationGuestsLabel;

  /// No description provided for @reservationCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'Пожелания (отдельный зал, детское место...)'**
  String get reservationCommentHint;

  /// No description provided for @reservationSendWhatsapp.
  ///
  /// In ru, this message translates to:
  /// **'Отправить бронь в WhatsApp'**
  String get reservationSendWhatsapp;

  /// No description provided for @reservationPhoneConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение придёт по телефону'**
  String get reservationPhoneConfirm;

  /// No description provided for @errorReservationContacts.
  ///
  /// In ru, this message translates to:
  /// **'Укажите имя и телефон'**
  String get errorReservationContacts;

  /// No description provided for @selectRequiredModifiers.
  ///
  /// In ru, this message translates to:
  /// **'Выберите обязательные опции'**
  String get selectRequiredModifiers;

  /// No description provided for @itemQuantityLine.
  ///
  /// In ru, this message translates to:
  /// **'{qty} шт · {total} тг'**
  String itemQuantityLine(int qty, String total);

  /// No description provided for @orderSentBodyLong.
  ///
  /// In ru, this message translates to:
  /// **'Ваш заказ отправлен в WhatsApp ресторана. Ожидайте подтверждения от оператора.'**
  String get orderSentBodyLong;

  /// No description provided for @reservationSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать стол'**
  String get reservationSubmit;

  /// No description provided for @reservationSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Запрос на бронирование отправлен!'**
  String get reservationSuccess;

  /// No description provided for @errorNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите имя'**
  String get errorNameRequired;

  /// No description provided for @errorGuestsRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите количество гостей'**
  String get errorGuestsRequired;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @profilePhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get profilePhone;

  /// No description provided for @profilePhoneMissing.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get profilePhoneMissing;

  /// No description provided for @profileLastAddress.
  ///
  /// In ru, this message translates to:
  /// **'Последний адрес доставки'**
  String get profileLastAddress;

  /// No description provided for @profileOrders.
  ///
  /// In ru, this message translates to:
  /// **'История заказов'**
  String get profileOrders;

  /// No description provided for @profileLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get profileLogout;

  /// No description provided for @profileLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get profileLanguage;

  /// No description provided for @languageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageKk.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get languageKk;

  /// No description provided for @ordersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои заказы'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Заказов пока нет'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Ваши заказы появятся здесь'**
  String get ordersEmptyHint;

  /// No description provided for @ordersError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String ordersError(String error);

  /// No description provided for @ordersMoreItems.
  ///
  /// In ru, this message translates to:
  /// **'+ ещё {count} позиц.'**
  String ordersMoreItems(int count);

  /// No description provided for @orderStatusPending.
  ///
  /// In ru, this message translates to:
  /// **'Принят'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждён'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнен'**
  String get orderStatusDone;

  /// No description provided for @itemNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Блюдо не найдено'**
  String get itemNotFound;

  /// No description provided for @loadError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки'**
  String get loadError;

  /// No description provided for @addToCart.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в корзину'**
  String get addToCart;

  /// No description provided for @halal.
  ///
  /// In ru, this message translates to:
  /// **'Халяль'**
  String get halal;

  /// No description provided for @spicy.
  ///
  /// In ru, this message translates to:
  /// **'Острое'**
  String get spicy;

  /// No description provided for @weightGrams.
  ///
  /// In ru, this message translates to:
  /// **'{weight} г'**
  String weightGrams(int weight);

  /// No description provided for @pushOrderConfirmedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ подтверждён'**
  String get pushOrderConfirmedTitle;

  /// No description provided for @pushOrderConfirmedBody.
  ///
  /// In ru, this message translates to:
  /// **'Ресторан принял ваш заказ'**
  String get pushOrderConfirmedBody;

  /// No description provided for @pushOrderDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ выполнен'**
  String get pushOrderDoneTitle;

  /// No description provided for @pushOrderDoneBody.
  ///
  /// In ru, this message translates to:
  /// **'Приятного аппетита!'**
  String get pushOrderDoneBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
