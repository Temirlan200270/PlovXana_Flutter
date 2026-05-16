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
│   ├── theme/
│   │   ├── app_colors.dart            # Цветовая палитра (константы)
│   │   └── app_theme.dart             # ThemeData (dark theme)
│   ├── router/
│   │   └── app_router.dart            # GoRouter: все маршруты
│   └── supabase/
│       └── supabase_config.dart       # URL + anonKey (заполнить!)
├── shared/
│   ├── models/                        # Dart-модели (Equatable)
│   │   ├── category.dart
│   │   ├── menu_item.dart
│   │   ├── cart_item.dart
│   │   ├── promotion.dart
│   │   └── reservation.dart
│   └── widgets/
│       └── main_scaffold.dart         # BottomNavigationBar + FAB корзины
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
    │           └── promo_banner.dart
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
    └── reservation/
        └── presentation/
            └── reservation_screen.dart # Датапикер + запись в reservations + WhatsApp
```

---

## Схема навигации

```
ShellRoute (MainScaffold — BottomNav + FAB)
├── /                    HomeScreen
├── /category/:id        CategoryScreen
└── /reservation         ReservationScreen

Вне ShellRoute (без BottomNav):
├── /item/:id            ItemDetailScreen
├── /cart                CartScreen
├── /checkout            CheckoutScreen
├── /order-sent          OrderSentScreen
└── /auth                AuthScreen
```

`MainScaffold` показывается только на трёх основных вкладках. При переходе на `/cart`, `/checkout`, `/auth` — обычный `Scaffold` без нижней навигации.

---

## Поток оформления заказа

```
HomeScreen / CategoryScreen
    ↓  (добавить в корзину)
CartScreen  ← FAB на MainScaffold
    ↓
CheckoutScreen
    ├── не авторизован → /auth → OTP → вернуться
    └── авторизован →
        ├── INSERT в таблицу orders (Supabase)
        └── открыть WhatsApp (wa.me/77074007728)
            ↓
        OrderSentScreen
```

---

## Цветовая палитра

| Имя | HEX | Назначение |
|---|---|---|
| `primary` | `#C9A84C` | Золото — акценты, кнопки |
| `background` | `#1A1A1A` | Фон приложения |
| `surface` | `#242424` | Карточки |
| `surfaceVariant` | `#2E2E2E` | Вложенные блоки |
| `cream` | `#F5EDD6` | Основной текст |
| `halal` | `#2E5339` | Бейдж "Халяль" |
| `spicy` | `#D4453A` | Бейдж "Острое" |
| `error` | `#CF6679` | Ошибки / SnackBar |

---

## Управление состоянием

Используется **Riverpod** (`StateNotifierProvider` + `FutureProvider`).

| Provider | Тип | Что хранит |
|---|---|---|
| `cartProvider` | `StateNotifierProvider` | `List<CartItem>` (in-memory) |
| `cartTotalProvider` | `Provider` | Сумма корзины в тенге |
| `cartCountProvider` | `Provider` | Количество позиций |
| `categoriesProvider` | `FutureProvider` | Список категорий из Supabase |
| `menuItemsByCategoryProvider` | `FutureProvider.family` | Блюда по `categoryId` |
| `popularItemsProvider` | `FutureProvider` | Популярные блюда (главная) |
| `promotionsProvider` | `FutureProvider` | Акции для баннеров |
