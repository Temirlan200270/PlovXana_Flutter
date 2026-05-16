# Архитектура

## Стек технологий

| Слой | Технология | Версия |
|---|---|---|
| UI | Flutter | 3.x |
| Язык | Dart | ^3.11.5 |
| State management | flutter_riverpod | ^2.6.1 |
| Навигация | go_router | ^14.8.1 |
| Backend | supabase_flutter | ^2.9.0 |
| Шрифты | google_fonts | ^6.2.1 |
| Изображения | cached_network_image | ^3.4.1 |
| Ссылки | url_launcher | ^6.3.1 |
| Локализация дат | intl | ^0.20.2 |

---

## Структура директорий

```
lib/
├── main.dart                          # Supabase, ProviderScope, GoRouter; debug: MarionetteBinding
├── core/
│   ├── config/
│   │   ├── app_config.dart            # WhatsApp, доставка (Павлодар)
│   │   ├── delivery_rules.dart        # Часы, min заказ, fee, formatTenge
│   │   └── user_prefs.dart            # Локальное имя/телефон
│   ├── theme/
│   │   ├── app_colors.dart            # Цветовая палитра (константы)
│   │   └── app_theme.dart             # ThemeData (dark theme)
│   ├── router/
│   │   └── app_router.dart            # GoRouter: initialLocation /splash
│   └── supabase/
│       └── supabase_config.dart       # URL + anonKey
├── shared/
│   ├── models/                        # Dart-модели (Equatable)
│   │   ├── category.dart
│   │   ├── menu_item.dart
│   │   ├── cart_item.dart
│   │   ├── promotion.dart
│   │   └── reservation.dart
│   └── widgets/
│       ├── main_scaffold.dart         # BottomNavigationBar + FloatingCartBar
│       ├── floating_cart_bar.dart     # Плашка корзины (Wolt-style)
│       ├── dish_image_placeholder.dart
│       ├── ikat_pattern_background.dart
│       ├── delivery_info_banner.dart
│       └── delivery_info_sheet.dart
└── features/
    ├── menu/
    │   ├── data/
    │   │   └── menu_providers.dart    # FutureProvider → Supabase
    │   └── presentation/
    │       ├── screens/
    │       │   ├── home_screen.dart
    │       │   ├── category_screen.dart
    │       │   └── item_detail_screen.dart
    │       └── widgets/
    │           ├── category_chip.dart
    │           ├── menu_item_card.dart
    │           ├── menu_shimmer.dart
    │           ├── promo_banner.dart
    │           └── shop_status_badge.dart
    ├── cart/
    │   ├── data/
    │   │   └── cart_provider.dart     # StateNotifierProvider (in-memory)
    │   └── presentation/
    │       └── cart_screen.dart
    ├── checkout/
    │   └── presentation/
    │       ├── checkout_screen.dart   # Форма + запись в orders + WhatsApp
    │       └── order_sent_screen.dart
    ├── auth/
    │   └── presentation/
    │       └── auth_screen.dart       # Phone OTP через Supabase
    ├── reservation/
    │   └── presentation/
    │       └── reservation_screen.dart # Датапикер + запись в reservations + WhatsApp
    ├── profile/
    │   └── presentation/
    │       └── screens/
    │           └── profile_screen.dart # Вкладка «Профиль»
    └── splash/
        └── presentation/
            └── splash_screen.dart      # Стартовый экран → /

integration_test/
└── smoke_test.dart                   # Patrol: splash, tabs, бронирование
```

---

## Схема навигации

```
/splash                  SplashScreen (initialLocation)

ShellRoute (MainScaffold — BottomNav + FloatingCartBar)
├── /                    HomeScreen
├── /category/:id        CategoryScreen  (?name= в query)
├── /reservation         ReservationScreen
└── /profile             ProfileScreen

Вне ShellRoute (без BottomNav и FloatingCartBar):
├── /item/:id            ItemDetailScreen  (MenuItem в extra; guard ниже)
├── /cart                CartScreen
├── /checkout            CheckoutScreen
├── /order-sent          OrderSentScreen
└── /auth                AuthScreen
```

`MainScaffold` оборачивает ShellRoute (`/`, `/category/:id`, `/reservation`, `/profile`).  
`FloatingCartBar` внутри scaffold — только на этих маршрутах.

При переходе на `/cart`, `/checkout`, `/auth`, `/item/:id` — отдельный `Scaffold` без нижней навигации и без плашки корзины.

### Guard `/item/:id`

В [`app_router.dart`](../lib/core/router/app_router.dart):

```dart
redirect: (c, s) => s.extra == null ? '/' : null,
```

Прямой deep link без `extra: MenuItem` → редирект на главную (защита от пустого экрана).

---

## Поток оформления заказа

```
SplashScreen (~2 с)
    ↓
HomeScreen / CategoryScreen
    ↓  (+ в MenuItemCard → FloatingCartBar: сумма блюд)
CartScreen  (кнопка «Оформить» — тоже сумма блюд)
    ↓
CheckoutScreen  (доставка 700 / бесплатно от 10 000 / самовывоз 0)
    ├── не авторизован → /auth → OTP → вернуться
    └── авторизован →
        ├── INSERT orders (total = блюда + доставка)
        └── WhatsApp (wa.me из AppConfig)
            ↓
        OrderSentScreen
```

---

## AppConfig

Файл: [`app_config.dart`](../lib/core/config/app_config.dart)

| Поле | Тип | Значение / назначение |
|---|---|---|
| `whatsappNumber` | `String` | `77074007728` (override: `--dart-define=WHATSAPP_NUMBER=...`) |
| `whatsappUrl` | `String` | `https://wa.me/{whatsappNumber}` |
| `deliveryPhoneDisplay` | `String` | `+7 707 400 77 28` |
| `deliveryFee` | `int` | 700 тг |
| `freeDeliveryThreshold` | `int` | 10 000 тг (сумма блюд) |
| `deliveryEtaMinMinutes` | `int` | 45 |
| `deliveryEtaMaxMinutes` | `int` | 75 |
| `deliveryCity` | `String` | `Павлодар` |
| `minDeliveryOrderAmount` | `int` | 3 000 тг — минимум суммы блюд для доставки |
| `shopOpenHour` | `int` | 11 — открытие |
| `shopLastOrderHour` | `int` | 22 — последний заказ (час) |
| `shopLastOrderMinute` | `int` | 45 — последний заказ (минуты) → **22:45** |
| `restaurant2GISUrl` | `String` | Ссылка на точку в 2GIS (тап в info-sheet на главной) |

Окно приёма заказов: **11:00–22:45** (после `shopLastOrder` ресторан «закрыт» для `isShopOpen()`).

---

## delivery_rules

Файл: [`delivery_rules.dart`](../lib/core/config/delivery_rules.dart)

Чистые функции (без Riverpod):

**Часы работы**

| Функция | Назначение |
|---|---|
| `isShopOpen()` | `true`, если сейчас между `shopOpenHour` и последним заказом (`shopLastOrderHour:Minute`) |
| `isClosingSoon()` | `true` за **30 минут** до последнего заказа (было хардкод 23:30 — теперь от `lastOrder - 30m`) |
| `shopClosedMessage()` | Текст для баннера checkout: до открытия / после последнего заказа |

**Минимальный заказ и доставка**

| Функция | Назначение |
|---|---|
| `minOrderError(subtotal, {isDelivery})` | `null` если ок; иначе строка «минимум 3 000 тг» (только доставка) |
| `deliveryFeeForSubtotal(subtotal, {isDelivery})` | 0 при самовывозе; 0 если subtotal ≥ порога; иначе `AppConfig.deliveryFee` |
| `orderGrandTotal(subtotal, deliveryFee)` | Сумма блюд + доставка |
| `formatTenge(amount)` | Форматирование с пробелами тысяч |
| `deliveryFeeShortLabel(subtotal, {isDelivery})` | `Бесплатно` / `700 тг` / `—` для UI checkout |
| `deliveryBannerSummary()` | Одна строка для `DeliveryInfoBanner` |

**Использование:** `ShopStatusBadge` → `isShopOpen()` / `isClosingSoon()`; `CheckoutScreen` → `canOrder = shopOpen && minErr == null`.

---

## user_prefs

Файл: [`user_prefs.dart`](../lib/core/config/user_prefs.dart)

Локальное хранилище через `SharedPreferences` (override в `main.dart`).

| Provider | Тип |
|---|---|
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` |
| `userPrefsProvider` | `StateNotifierProvider<UserPrefsNotifier, UserPrefsState>` |

### `UserPrefsState`

| Поле | Ключ в prefs |
|---|---|
| `name` | `user_name` |
| `phone` | `user_phone` |
| `lastAddress` | `user_last_address` |

### `UserPrefsNotifier`

| Метод | Действие |
|---|---|
| `save(name, phone)` | Запись имени и телефона |
| `saveAddress(address)` | Последний адрес доставки (если не пустой) |

**Использование:** автозаполнение в `CheckoutScreen` и `ReservationScreen`.

---

## Справочник виджетов

| Компонент | Путь | Назначение |
|---|---|---|
| `SplashScreen` | `lib/features/splash/presentation/splash_screen.dart` | Старт `/splash` → `/` |
| `ProfileScreen` | `lib/features/profile/presentation/screens/profile_screen.dart` | Вкладка `/profile` |
| `ShopStatusBadge` | `lib/features/menu/presentation/widgets/shop_status_badge.dart` | `isShopOpen()` / `isClosingSoon()` из `delivery_rules.dart` |
| `DeliveryInfoBanner` | `lib/shared/widgets/delivery_info_banner.dart` | Плашка условий на главной |
| `DeliveryInfoSheet` | `lib/shared/widgets/delivery_info_sheet.dart` | Bottom sheet; `showDeliveryInfoSheet(context)` |
| `IkatPatternBackground` | `lib/shared/widgets/ikat_pattern_background.dart` | Орнамент `accentBlue` @ 4% |
| `FloatingCartBar` | `lib/shared/widgets/floating_cart_bar.dart` | Плашка корзины в `MainScaffold` |
| `DishImagePlaceholder` | `lib/shared/widgets/dish_image_placeholder.dart` | Заглушка фото блюда |

### `ShopStatusBadge` — состояния

| Условие | Текст | Цвет точки |
|---|---|---|
| `isClosingSoon()` | Закроется скоро | `primary` |
| `isShopOpen()` | Сейчас открыто | `halal` |
| иначе | Закрыто до 11:00 | `error` |

---

## Провайдеры меню

Файл: [`menu_providers.dart`](../lib/features/menu/data/menu_providers.dart)

| Provider | Тип | Кратко |
|---|---|---|
| `supabaseProvider` | `Provider` | `Supabase.instance.client` |
| `signOutProvider` | `Provider` | `() => client.auth.signOut()` |
| `categoriesProvider` | `FutureProvider` | Категории с доступными блюдами |
| `menuItemsByCategoryProvider` | `FutureProvider.family` | Блюда категории |
| `popularItemsProvider` | `FutureProvider` | `is_popular` или fallback 10 |
| `newItemsProvider` | `FutureProvider` | По `created_at` desc, limit 10 |
| `promotionsProvider` | `FutureProvider` | `active = true` |
| `searchQueryProvider` | `StateProvider<String>` | Текст в поле поиска (UI) |
| `searchProvider` | `AsyncNotifierProvider.autoDispose` | `SearchNotifier` — debounce **300 ms**, затем запрос |
| `SearchNotifier` | `AutoDisposeAsyncNotifier` | `search(query)`: `ilike` по имени, `is_available`, limit 20 |

Поиск: `searchQueryProvider` синхронизирует поле; `searchProvider.notifier.search(v)` — отложенный запрос.

---

## Тестирование (Patrol)

Файл: [`pubspec.yaml`](../pubspec.yaml)

| Пакет | Секция | Назначение |
|---|---|---|
| `patrol` | `dev_dependencies` | E2E-тесты (нативная автоматизация) |
| `marionette_mcp` | `dev_dependencies` | MCP для UI в debug |
| `marionette_flutter` | `dependencies` | `MarionetteBinding` в `main.dart` (только `kDebugMode`) |

Конфиг Patrol в `pubspec.yaml`:

```yaml
patrol:
  app_name: ПЛОВ НОМЕР 1
  android:
    package_name: kz.plovxana.plovxana
  ios:
    bundle_id: kz.plovxana.plovxana
```

Smoke-тесты: [`integration_test/smoke_test.dart`](../integration_test/smoke_test.dart)

| Сценарий | Проверка |
|---|---|
| Splash screen | Виден текст «ПЛОВ НОМЕР 1» |
| После splash | BottomNav: «Меню», «Бронь», «Профиль» |
| Переход на Бронь | Заголовок «Бронирование стола» |

Запуск:

```bash
patrol test --target integration_test/smoke_test.dart
```

---

## Цветовая палитра

Полная спека → [design-system.md](design-system.md). Premium Uzbek → [Premium Uzbek](design-system.md#premium-uzbek--направление-айдентики).

| Имя | HEX | Назначение |
|---|---|---|
| `primary` | `#C9A84C` | Золото — кнопки, цены, FloatingCartBar |
| `background` | `#1A1A1A` | Фон приложения |
| `surface` | `#242424` | Карточки |
| `surfaceVariant` | `#2E2E2E` | Вложенные блоки, плейсхолдеры |
| `cream` | `#F5EDD6` | Основной текст |
| `halal` | `#2E5339` | Бейдж «Халяль», точка «открыто» |
| `spicy` | `#D4453A` | Бейдж «Острое» |
| `accentBlue` | `#1D7898` | Самаркандский лазурь — категории, икат |
| `accentTerracotta` | `#A73C27` | Терракота (резерв) |
| `error` | `#CF6679` | Ошибки / SnackBar |

---

## Управление состоянием

Используется **Riverpod** (`StateNotifierProvider` + `FutureProvider`).

| Provider | Тип | Что хранит |
|---|---|---|
| `cartProvider` | `StateNotifierProvider` | `List<CartItem>` (in-memory) |
| `cartTotalProvider` | `Provider` | Сумма **блюд** в тенге (без доставки) |
| `cartCountProvider` | `Provider` | Количество позиций (шт.) |
| `supabaseProvider` | `Provider` | Клиент `Supabase.instance.client` |
| `signOutProvider` | `Provider` | Callback выхода из сессии |
| `categoriesProvider` | `FutureProvider` | Категории с доступными блюдами |
| `menuItemsByCategoryProvider` | `FutureProvider.family` | Блюда по `categoryId`, `is_available` |
| `popularItemsProvider` | `FutureProvider` | `is_popular` или fallback 10 блюд |
| `newItemsProvider` | `FutureProvider` | Новинки по `created_at` |
| `promotionsProvider` | `FutureProvider` | Активные акции |
| `searchQueryProvider` | `StateProvider` | Текст в поле поиска |
| `searchProvider` | `AsyncNotifierProvider.autoDispose` | Поиск с debounce 300 ms |
| `sharedPreferencesProvider` | `Provider` | `SharedPreferences` — [`user_prefs.dart`](../lib/core/config/user_prefs.dart), override в `main` |
| `userPrefsProvider` | `StateNotifierProvider` | `UserPrefsState`: имя, телефон, последний адрес |
