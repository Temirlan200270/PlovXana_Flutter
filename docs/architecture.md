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
├── main.dart                          # Точка входа: Supabase.init, ProviderScope, GoRouter
├── core/
│   ├── config/
│   │   ├── app_config.dart            # WhatsApp, доставка (Павлодар)
│   │   ├── delivery_rules.dart        # Расчёт fee, formatTenge, тексты баннера
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
    └── splash/
        └── presentation/
            └── splash_screen.dart      # Стартовый экран → /
```

---

## Схема навигации

```
/splash                SplashScreen (initial)

ShellRoute (MainScaffold — BottomNav + FloatingCartBar)
├── /                    HomeScreen
├── /category/:id        CategoryScreen
└── /reservation         ReservationScreen

Вне ShellRoute (без BottomNav и FloatingCartBar):
├── /splash              SplashScreen (только initial)
├── /item/:id            ItemDetailScreen
├── /cart                CartScreen
├── /checkout            CheckoutScreen
├── /order-sent          OrderSentScreen
└── /auth                AuthScreen
```

`MainScaffold` оборачивает ShellRoute (`/`, `/category/:id`, `/reservation`).  
`FloatingCartBar` внутри scaffold — только на этих маршрутах.

При переходе на `/cart`, `/checkout`, `/auth`, `/item/:id` — отдельный `Scaffold` без нижней навигации и без плашки корзины.

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

## Конфигурация доставки

| Константа (`AppConfig`) | Значение |
|---|---|
| `deliveryFee` | 700 тг |
| `freeDeliveryThreshold` | 10 000 тг |
| `deliveryEtaMinMinutes` / `Max` | 45–75 мин |
| `deliveryCity` | Павлодар |
| `deliveryPhoneDisplay` | +7 707 400 77 28 |

Логика: [`delivery_rules.dart`](../lib/core/config/delivery_rules.dart) — `deliveryFeeForSubtotal`, `orderGrandTotal`, `deliveryBannerSummary`.

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
| `categoriesProvider` | `FutureProvider` | Список категорий из Supabase |
| `menuItemsByCategoryProvider` | `FutureProvider.family` | Блюда по `categoryId` |
| `popularItemsProvider` | `FutureProvider` | Популярные блюда (главная) |
| `promotionsProvider` | `FutureProvider` | Акции для баннеров |
