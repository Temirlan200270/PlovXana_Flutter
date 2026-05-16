# Описание экранов и функций

## Splash (`SplashScreen`)

**Маршрут:** `/splash` (стартовый)

- Тёмный фон `AppColors.background`, `IkatPatternBackground`
- Заголовок «ПЛОВ НОМЕР 1» (золото), fade + scale ~2 с → `context.go('/')`
- Native splash Android/iOS: фон `#1A1A1A`

---

## Главный экран (`HomeScreen`)

**Маршрут:** `/`

- **AppBar:** «ПЛОВ НОМЕР 1» (Playfair), `ShopStatusBadge`, доставка (sheet), выход и «О ресторане»
- **Поиск:** `IkatPatternBackground` + поле; `searchQueryProvider` → `searchResultsProvider`
- **Акции:** `PromoBanner` — арочные углы 24/16, fallback с лазурной полосой `accentBlue`
- **Доставка:** `DeliveryInfoBanner` под акциями → `DeliveryInfoSheet` (700 тг, бесплатно от 10 000 тг, Павлодар, 45–75 мин)
- **Категории:** `CategoryChip` (96×80, арка, рамка `accentBlue`, иконка по типу кухни) → `/category/:id`
- **Популярное / Новинки:** `MenuItemCard` — казан-заглушка, stepper `[ − qty + ]`
- **Состояния:** `MenuShimmer` при загрузке, пустой поиск — «Ничего не найдено»

Данные: `categoriesProvider`, `popularItemsProvider`, `newItemsProvider`, `promotionsProvider`.

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

UI: «Сумма блюд» + «Доставка» + «Итого». `FloatingCartBar` показывает только сумму блюд.

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
| Время | 13:00 | системный пикер |
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

## MainScaffold (общая оболочка)

**Файлы:** `main_scaffold.dart`, `floating_cart_bar.dart`, `dish_image_placeholder.dart`, `ikat_pattern_background.dart`, `delivery_info_banner.dart`, `delivery_info_sheet.dart`

### BottomNavigationBar

| Индекс | Метка | Маршрут |
|---|---|---|
| 0 | Меню | `/` |
| 1 | Бронь | `/reservation` |

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

Тексты баннера генерируются в `deliveryBannerSummary()` из `AppConfig`.

Маршруты `/splash`, `/cart`, `/checkout`, `/auth`, `/item/:id` — **вне** ShellRoute (без нижнего меню; `/splash` и checkout — без FloatingCartBar).
