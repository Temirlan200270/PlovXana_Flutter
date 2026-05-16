# Описание экранов и функций

> Справочник путей, `AppConfig`, `delivery_rules`, `user_prefs`, Patrol — [architecture.md](architecture.md#справочник-виджетов).

## Splash (`SplashScreen`)

**Файл:** [`lib/features/splash/presentation/splash_screen.dart`](../lib/features/splash/presentation/splash_screen.dart)  
**Маршрут:** `/splash` (стартовый)

- Тёмный фон `AppColors.background`, `IkatPatternBackground`
- Заголовок «ПЛОВ НОМЕР 1» (золото, `displaySmall`), анимация 1200 ms + задержка 2000 ms → `context.go('/')`
- Native splash Android/iOS: фон `#1A1A1A`

---

## Главный экран (`HomeScreen`)

**Маршрут:** `/`

- **AppBar:** «ПЛОВ НОМЕР 1» (Playfair), [`ShopStatusBadge`](../lib/features/menu/presentation/widgets/shop_status_badge.dart) — [`isShopOpen()` / `isClosingSoon()`](../lib/core/config/delivery_rules.dart) (окно 11:00–22:45, «скоро» за 30 мин до последнего заказа), иконки: доставка → sheet, выход, info → 2GIS
- **Поиск:** `IkatPatternBackground` + поле; `searchQueryProvider` + `searchProvider` (`SearchNotifier`, debounce **300 ms**, `autoDispose`); при непустом запросе — только сетка результатов, блоки акций/категорий/популярного скрыты
- **Акции:** `PromoBanner` — арочные углы 24/16, fallback с лазурной полосой `accentBlue`
- **Доставка:** [`DeliveryInfoBanner`](../lib/shared/widgets/delivery_info_banner.dart) под акциями → [`DeliveryInfoSheet`](../lib/shared/widgets/delivery_info_sheet.dart)
- **Категории:** горизонтальный скролл `CategoryChip` → `/category/:id?name=...` (только категории с доступными блюдами)
- **Популярное / Новинки:** двухрядная горизонтальная сетка (`SliverMainAxisGroup`, высота 480, `childAspectRatio: 1.25`), `MenuItemCard`
- **Состояния:** `MenuShimmer` пока грузятся категории + популярное; пустой поиск — «Ничего не найдено»

### Провайдеры ([`menu_providers.dart`](../lib/features/menu/data/menu_providers.dart))

| Provider | Логика |
|---|---|
| `categoriesProvider` | Категории с `sort_order`, **только где есть `menu_items` с `is_available = true`** |
| `popularItemsProvider` | `is_popular = true`, limit 10; если пусто — fallback: первые 10 доступных блюд |
| `newItemsProvider` | Последние по `created_at`, limit 10 |
| `promotionsProvider` | `active = true`, по `created_at` desc |
| `searchQueryProvider` | `StateProvider<String>` — текст в поле |
| `searchProvider` | `SearchNotifier` — debounce 300 ms, `ilike` по имени, limit 20 |
| `signOutProvider` | `Supabase.auth.signOut()` |

---

## Экран категории (`CategoryScreen`)

**Маршрут:** `/category/:id?name=Название` — заголовок AppBar из query-параметра `name`

- Сетка блюд категории (`menuItemsByCategoryProvider`)
- Только `is_available = true`
- Карточка `MenuItemCard`: фото, название, вес, цена, stepper корзины `[ − qty + ]`
- Tap по карточке → `/item/:id`

---

## Детальная страница блюда (`ItemDetailScreen`)

**Маршрут:** `/item/:id` (объект `MenuItem` в `extra`)

**Guard:** если `extra == null` → редирект на `/` ([`app_router.dart`](../lib/core/router/app_router.dart)).

- Hero в `SliverAppBar`; без фото — `DishImagePlaceholder` (казан)
- Описание, вес, бейджи «Халяль» / «Острое»
- Нижняя панель: «Добавить в корзину» или stepper с итогом за позицию

---

## Корзина (`CartScreen`)

**Маршрут:** `/cart`

**Доступ:**

- Тап по `FloatingCartBar` (на вкладках с `MainScaffold`)
- Прямой переход по маршруту (без нижнего меню)

**Содержимое:**

- Список позиций: `+` / `−` / удалить
- Кнопка «Оформить · X тг» — сумма **блюд** (`cartTotalProvider`), без доставки
- «Оформить заказ» → `/checkout`
- Пустая корзина — `IkatPatternBackground`, `DishImagePlaceholder`, CTA «В меню»
- Миниатюры без фото — `DishImagePlaceholder` 88×88

**Состояние:** in-memory (`CartNotifier` / `cartProvider`), сбрасывается при перезапуске.

---

## Оформление заказа (`CheckoutScreen`)

**Маршрут:** `/checkout`

### Автозаполнение

При открытии подставляются `userPrefsProvider` (`name`, `phone`, `lastAddress`). После успешного заказа — `save()` / `saveAddress()`.

### Поля формы

| Поле | Обязательное | Описание |
|---|---|---|
| Тип получения | Да | Доставка / Самовывоз |
| Адрес | Если доставка | Улица, дом, квартира |
| Имя | Нет | Автозаполнение из профиля |
| Телефон | Да | Префикс +7, 10 цифр |
| Комментарий | Нет | Пожелания, аллергии |

### Сумма заказа

Константы в [`app_config.dart`](../lib/core/config/app_config.dart), расчёт в [`delivery_rules.dart`](../lib/core/config/delivery_rules.dart):

| Условие | Доставка |
|---|---|
| Самовывоз | 0 тг |
| Доставка, сумма блюд ≥ 10 000 тг | Бесплатно |
| Доставка, сумма блюд &lt; 10 000 тг | 700 тг |
| Минимум для доставки | 3 000 тг (`minDeliveryOrderAmount`) — только доставка |

UI: «Сумма блюд» + «Доставка» + «Итого». `FloatingCartBar` показывает только сумму блюд.

### Валидация перед отправкой

```dart
canOrder = isShopOpen() && minOrderError(subtotal, isDelivery: ...) == null && !_loading
```

| Баннер | Цвет | Когда |
|---|---|---|
| `shopClosedMessage()` | `AppColors.error` (красный) | Ресторан закрыт (`!isShopOpen()`) |
| `minOrderError(...)` | `AppColors.primary` (золотой) | Сумма блюд &lt; 3 000 тг при доставке |

Кнопка «Отправить заказ в WhatsApp» **disabled**, если `!canOrder`.

### Логика отправки

1. Если пользователь не авторизован — редирект на `/auth`
2. Запись заказа в таблицу `orders` (Supabase), `total` = итог с доставкой
3. Открытие WhatsApp с готовым сообщением на номер `+7 707 400 77 28`
4. Очистка корзины → переход на `/order-sent`

Если запись в Supabase упала (нет сети) — заказ всё равно уходит в WhatsApp.

### Формат WhatsApp-сообщения

```
🍽 Новый заказ — ПЛОВ НОМЕР 1

📋 Состав:
- Плов классический x2 — 5 000 тг
- Шашлык из баранины x1 — 4 500 тг

🍽 Сумма блюд: 9 500 тг
🚚 Доставка: 700 тг
💰 Итого: 10 200 тг
🚗 Доставка
💵 Оплата: Наличные / Kaspi перевод
📍 Адрес: ул. Абая 10, кв 5
👤 Имя: Асан
📞 Телефон: +77771234567

⏰ 14:32
```

Строка `🚚 Доставка:` — только при типе «Доставка» (`Бесплатно` или `700 тг`). При самовывозе — без неё.

---

## Экран после заказа (`OrderSentScreen`)

**Маршрут:** `/order-sent`

- Подтверждение отправки заказа
- «Вернуться в меню» → `/`

---

## Авторизация (`AuthScreen`)

**Маршрут:** `/auth`  
**Когда:** оформление заказа без сессии

### Шаг 1 — телефон

- +7 и 10 цифр
- «Получить код» → `signInWithOtp`

### Шаг 2 — OTP

- 6 цифр из SMS → `verifyOTP`
- Успех → `context.pop()` на checkout
- «Изменить номер» → шаг 1

SMS-провайдер: [supabase-setup.md](supabase-setup.md).

---

## Бронирование стола (`ReservationScreen`)

**Маршрут:** `/reservation`  
**Доступ:** вкладка BottomNavigationBar

### Поля

| Поле | По умолчанию | Ограничения |
|---|---|---|
| Дата | Завтра | сегодня … +60 дней |
| Время | 13:00 | системный пикер; в БД и WhatsApp — `_formatTime()` → всегда `HH:mm` (например `09:05`) |
| Гости | 2 | 1–20 |
| Имя | — | обязательно |
| Телефон | — | обязательно |
| Комментарий | — | опционально |

### UI

- `prefixIcon` с отступом `left: 16`, `right: 12`
- Кнопка отправки: `ElevatedButton` + `Row` (иконка и текст с `SizedBox(width: 8)`)

### Логика

1. `INSERT` в `reservations` (без обязательной авторизации)
2. WhatsApp с текстом брони
3. SnackBar «Запрос на бронирование отправлен!»

### Формат WhatsApp

```
🍽 Бронирование стола — ПЛОВ НОМЕР 1

👤 Имя: Асан
📞 Телефон: +77771234567
📅 Дата: 20.05.2026
⏰ Время: 13:00
👥 Гостей: 4
💬 Отдельный зал
```

---

## Профиль (`ProfileScreen`)

**Файл:** [`lib/features/profile/presentation/screens/profile_screen.dart`](../lib/features/profile/presentation/screens/profile_screen.dart)  
**Маршрут:** `/profile` (вкладка BottomNav)

- Аватар-заглушка, имя из `userPrefsProvider`
- Телефон: Supabase `currentUser.phone` или `+7` + prefs
- Последний адрес доставки (если сохранён)
- Переключатель языка: **Русский / Қазақша** (`localeProvider`, ключ `app_locale` в SharedPreferences)
- Ссылка «История заказов» → `/orders`
- Кнопка «Выйти из аккаунта» → `signOutProvider` (удаляет FCM-токен)

---

## История заказов (`OrdersScreen`)

**Файл:** [`lib/features/orders/presentation/screens/orders_screen.dart`](../lib/features/orders/presentation/screens/orders_screen.dart)  
**Маршрут:** `/orders`

- Список `orders` текущего пользователя (`ordersProvider`)
- Статусы в UI: Принят / Подтверждён / Выполнен (локализованы)
- Тап по пушу о статусе → этот экран

---

## Мультиязычность (ru / kk)

| Что | Детали |
|---|---|
| Файлы | `lib/l10n/app_ru.arb`, `app_kk.arb` → `flutter gen-l10n` |
| Провайдер | [`locale_provider.dart`](../lib/core/l10n/locale_provider.dart) |
| UI | Все экраны через `context.l10n` / [`delivery_l10n.dart`](../lib/core/l10n/delivery_l10n.dart) |
| Меню | Названия блюд из Supabase **не переводятся** (как в iiko) |
| По умолчанию | Русский; казахский — в профиле |

---

## Пуш-уведомления (статус заказа)

**MVP:** только смена `orders.status` менеджером в Supabase.

| Переход | Пуш |
|---|---|
| `pending` → `confirmed` | Заказ подтверждён |
| `confirmed` → `done` | Заказ выполнен |

| Компонент | Путь |
|---|---|
| FCM-клиент | [`fcm_service.dart`](../lib/features/notifications/data/fcm_service.dart) |
| Токены в БД | таблица `push_tokens` (миграция `20260516120000_push_tokens.sql`) |
| Edge Function | [`send-order-push`](../supabase/functions/send-order-push/index.ts) |
| Настройка | [supabase-setup.md](supabase-setup.md#push-уведомления-fcm) |

Токен регистрируется после OTP и при смене языка; при выходе удаляется.

---

## MainScaffold (общая оболочка)

**Файлы:** [`main_scaffold.dart`](../lib/shared/widgets/main_scaffold.dart), [`floating_cart_bar.dart`](../lib/shared/widgets/floating_cart_bar.dart), [`dish_image_placeholder.dart`](../lib/shared/widgets/dish_image_placeholder.dart), [`ikat_pattern_background.dart`](../lib/shared/widgets/ikat_pattern_background.dart), [`delivery_info_banner.dart`](../lib/shared/widgets/delivery_info_banner.dart), [`delivery_info_sheet.dart`](../lib/shared/widgets/delivery_info_sheet.dart)

### BottomNavigationBar

| Индекс | Метка | Маршрут |
|---|---|---|
| 0 | Меню | `/` |
| 1 | Бронь | `/reservation` |
| 2 | Профиль | `/profile` |

### FloatingCartBar

| Условие | Поведение |
|---|---|
| `cartCount == 0` | Скрыта (`SizedBox.shrink`, анимация `AnimatedSize`) |
| `cartCount > 0` | Золотая плашка: badge, «Корзина · N блюд», сумма в тг, стрелка |
| Тап | `context.push('/cart')` |

**Провайдеры:** `cartCountProvider`, `cartTotalProvider` ([`cart_provider.dart`](../lib/features/cart/data/cart_provider.dart)). Сумма на плашке — только блюда.

### Условия доставки (UI)

| Компонент | Файл | Действие |
|---|---|---|
| `DeliveryInfoBanner` | `delivery_info_banner.dart` | Плашка под акциями на главной |
| `showDeliveryInfoSheet` | `delivery_info_sheet.dart` | Bottom sheet с полными условиями |
| AppBar (главная) | `home_screen.dart` | Иконка доставки → тот же sheet |

Тексты баннера — `context.l10n.deliveryBannerSummary()` (локализовано).

Маршруты `/splash`, `/cart`, `/checkout`, `/auth`, `/item/:id` — **вне** ShellRoute (без нижнего меню; `/splash` и checkout — без FloatingCartBar).
