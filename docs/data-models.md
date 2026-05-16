# Модели данных

## Dart-модели

### `Category`

```dart
// lib/shared/models/category.dart
class Category extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int sortOrder;
}
```

Таблица Supabase: `categories`

---

### `MenuItem`

```dart
// lib/shared/models/menu_item.dart
class MenuItem extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final int price;         // в тенге
  final String? imageUrl;
  final int? weightG;      // граммы
  final bool isHalal;
  final bool isSpicy;
  final bool isAvailable;
  final int sortOrder;
}
```

Таблица Supabase: `menu_items`

---

### `CartItem`

```dart
// lib/shared/models/cart_item.dart
class CartItem extends Equatable {
  final MenuItem item;
  final int quantity;

  int get total => item.price * quantity;
}
```

Хранится только в памяти (`CartNotifier`). В Supabase не сохраняется.

---

### `Promotion`

```dart
// lib/shared/models/promotion.dart
class Promotion extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final bool active;
}
```

Таблица Supabase: `promotions`

---

### `Reservation`

```dart
// lib/shared/models/reservation.dart
// Используется только при записи в Supabase
// (нет Dart-модели для чтения, данные пишутся напрямую через Map)
```

---

## Схема базы данных

### `categories`

| Колонка | Тип | Описание |
|---|---|---|
| `id` | uuid (PK) | auto |
| `name` | text | Название категории |
| `image_url` | text? | URL изображения |
| `sort_order` | integer | Порядок отображения |
| `created_at` | timestamptz | auto |

### `menu_items`

| Колонка | Тип | Описание |
|---|---|---|
| `id` | uuid (PK) | auto |
| `category_id` | uuid (FK) | → `categories.id` ON DELETE CASCADE |
| `name` | text | Название |
| `description` | text? | Описание |
| `price` | integer | Цена в тенге (целое) |
| `image_url` | text? | URL фото |
| `weight_g` | integer? | Вес в граммах |
| `is_halal` | boolean | default `true` |
| `is_spicy` | boolean | default `false` |
| `is_available` | boolean | default `true` (скрытые не показываются) |
| `is_popular` | boolean | default `false` (для блока на главной) |
| `sort_order` | integer | Порядок в категории |
| `created_at` | timestamptz | auto |

### `promotions`

| Колонка | Тип | Описание |
|---|---|---|
| `id` | uuid (PK) | auto |
| `title` | text | Заголовок акции |
| `description` | text? | Описание |
| `image_url` | text? | Баннер |
| `active` | boolean | default `true` |
| `created_at` | timestamptz | auto |

### `orders`

| Колонка | Тип | Описание |
|---|---|---|
| `id` | uuid (PK) | auto |
| `user_id` | uuid (FK)? | → `auth.users.id` |
| `status` | text | `pending` / `confirmed` / `done` |
| `items_json` | jsonb | `[{item_id, name, price, quantity}]` |
| `total` | integer | Итог в тенге: сумма блюд + доставка (см. `delivery_rules.dart`) |
| `delivery_type` | text | `delivery` / `pickup` |
| `address` | text? | Адрес доставки |
| `phone` | text? | Телефон клиента |
| `comment` | text? | Комментарий |
| `created_at` | timestamptz | auto |

### `reservations`

| Колонка | Тип | Описание |
|---|---|---|
| `id` | uuid (PK) | auto |
| `user_id` | uuid (FK)? | Может быть NULL (гость) |
| `date` | date | Дата брони |
| `time` | time | Время брони |
| `guests_count` | integer | Количество гостей |
| `comment` | text? | Пожелания |
| `phone` | text? | Контактный телефон |
| `name` | text? | Имя гостя |
| `status` | text | `pending` / `confirmed` / `cancelled` |
| `created_at` | timestamptz | auto |

---

## RLS-политики (Row Level Security)

| Таблица | Политика | Операция | Условие |
|---|---|---|---|
| `categories` | `categories_read_all` | SELECT | `true` (все) |
| `menu_items` | `menu_items_read_all` | SELECT | `true` (все) |
| `promotions` | `promotions_read_all` | SELECT | `true` (все) |
| `orders` | `orders_insert_own` | INSERT | `auth.uid() = user_id` |
| `orders` | `orders_select_own` | SELECT | `auth.uid() = user_id` |
| `reservations` | `reservations_insert_own` | INSERT | `true` (гости тоже могут) |
| `reservations` | `reservations_select_own` | SELECT | `auth.uid() = user_id OR user_id IS NULL` |

Только авторизованные пользователи могут оформлять заказы.  
Бронирование доступно всем (авторизованным и гостям).

---

## Запросы к Supabase

### Категории (sorted)
```dart
client.from('categories').select().order('sort_order').order('name')
```

### Блюда по категории
```dart
client.from('menu_items')
  .select()
  .eq('category_id', categoryId)
  .eq('is_available', true)
  .order('sort_order')
  .order('name')
```

### Популярные блюда
```dart
client.from('menu_items')
  .select()
  .eq('is_available', true)
  .eq('is_popular', true)
  .order('sort_order')
  .limit(10)
```

### Запись заказа
```dart
client.from('orders').insert({
  'user_id': user.id,
  'status': 'pending',
  'items_json': [...],
  'total': grandTotal, // блюда + deliveryFee
  'delivery_type': 'delivery',
  'address': address,
  'phone': phone,
  'comment': comment,
})
```
