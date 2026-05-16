# Design System — ПЛОВ НОМЕР 1

Централизованные UI-правила. **Любое отклонение требует явного решения**, а не вкусовщины.

## Дизайн-философия

**Premium Uzbek** — текущий образ (v1 внедрён). База: тёмный фон + золото + кремовый текст.

Тёмный фон (ночной ресторан), золото-акцент (лампы, медь), кремовая типографика (тёплый свет на скатерти) — это уже работает и даёт ощущение «дорого». Но без узбекских маркеров интерфейс без логотипа похож на стейк-хаус, суши-бар или кальянную: есть премиальность, **нет узбекской души**.

**Правило эволюции:** усиливать айдентику **поверх** существующей системы. Не «колхоз» и не пёстрая чайхана — элегантные этнические акценты, а не перерисовка всего UI.

Это **не Material Design** в чистом виде. Не **Cupertino**. Собственный язык под узбекскую кухню в дорогом сегменте.

---

## Premium Uzbek — направление айдентики

Четыре рычага поверх тёмно-золотой базы. **Внедрено** (см. таблицу статуса ниже).

### 1. Этнические цвета ✅

| Token | HEX | Где используется |
|---|---|---|
| `accentBlue` / `samarkandBlue` | `#1D7898` | Рамка `CategoryChip`, `IkatPatternBackground`, полоска fallback в `PromoBanner` |
| `accentTerracotta` / `tandoor` | `#A73C27` | Резерв (пока не в UI; `spicy` для «Острое») |

**Правило:** `background`, `cream`, `primary` и **FloatingCartBar** не перекрашивать в лазурь/терракоту.

### 2. Плейсхолдеры фото ✅

Виджет [`DishImagePlaceholder`](../lib/shared/widgets/dish_image_placeholder.dart):

- Иконка: `Icons.soup_kitchen_rounded` (казан), цвет `AppColors.divider`
- Фон: `AppColors.surfaceVariant`

**Подключено:** `MenuItemCard`, `ItemDetailScreen`, миниатюры и пустая корзина в `CartScreen`.

**Категории:** иконки по названию (`CategoryChip.iconForCategory`) — `rice_bowl`, `soup_kitchen_rounded` и т.д.

**Позже (опционально):** SVG казана в `assets/images/placeholders/`.

### 3. Паттерн икат ✅

Виджет [`IkatPatternBackground`](../lib/shared/widgets/ikat_pattern_background.dart) — `CustomPainter`, ромбы, `accentBlue` @ **4%** opacity.

**Подключено:** блок поиска на `HomeScreen`, пустое состояние `CartScreen`.

**Не использовать** под плотным текстом форм. Один стиль паттерна на весь проект.

### 4. Мягкие арки ✅

| Компонент | Радиусы (верх / низ) |
|---|---|
| `CategoryChip` | 24 / 16, контейнер 80×80 |
| `PromoBanner` | 24 / 16 |
| `MenuItemCard` | 16 равномерно (контент-карточка) |

**Не делать:** арки на каждой кнопке; не выходить за spacing scale 4/8/12…

### Типографика логотипа

| Зона | Шрифт | Комментарий |
|---|---|---|
| Меню, формы, цены | **Inter** | Читаемость — приоритет |
| «ПЛОВ НОМЕР 1» в AppBar | Playfair Display (сейчас) или восточный display-шрифт | Только заголовок бренда; лёгкая вязь — опционально, A/B с Playfair |
| Body / описания блюд | Inter | Без декоративных шрифтов |

### Лоадеры

`CircularProgressIndicator` — цвет `AppColors.primary` (золото). Опционально: кастомный индикатор «солнце» / орнамент — только на splash и full-screen loading, не на каждой кнопке.

---

## 🛠 Premium Uzbek — статус внедрения

| Шаг | Статус | Где в коде |
|---|---|---|
| `accentBlue`, `accentTerracotta` | ✅ | `app_colors.dart` |
| Плейсхолдер казан | ✅ | `DishImagePlaceholder` → карточки, корзина, деталь |
| Паттерн икат (~4% opacity) | ✅ | `IkatPatternBackground` → поиск, пустая корзина |
| Арки 24/16 | ✅ | `CategoryChip`, `PromoBanner` |
| Display-шрифт заголовка | ⏳ | Playfair в AppBar — опционально позже |

Виджеты: [`dish_image_placeholder.dart`](../lib/shared/widgets/dish_image_placeholder.dart), [`ikat_pattern_background.dart`](../lib/shared/widgets/ikat_pattern_background.dart).

---

## 🎨 Color tokens

Все цвета — в [lib/core/theme/app_colors.dart](../lib/core/theme/app_colors.dart). **Никаких inline `Color(0xFF...)` в widget-коде.**

### Brand

| Token | HEX | Использование |
|---|---|---|
| `primary` | `#C9A84C` | Золото. Кнопки, акценты, активные элементы. Бейджи цены. |
| `cream` | `#F5EDD6` | Основной текст. Заголовки, body. |
| `halal` | `#2E5339` | Бейдж "Халяль". Тёмно-зелёный — отличается от любого другого UI. |
| `spicy` | `#D4453A` | Бейдж "Острое". Используется только тут, не как error. |
| `accentBlue` | `#1D7898` | Самаркандский лазурь. Рамка категорий, паттерн, акценты промо. |
| `accentTerracotta` | `#A73C27` | Терракота. Резерв для тёплых акцентов. |

### Surface

| Token | HEX | Использование |
|---|---|---|
| `background` | `#1A1A1A` | Скаффолд, основной фон |
| `surface` | `#242424` | Карточки, inputs, dialog'и |
| `surfaceVariant` | `#2E2E2E` | Вложенные блоки (карточка внутри карточки) |
| `divider` | `#333333` | Границы, разделители |

### Text

| Token | HEX | Использование |
|---|---|---|
| `cream` | `#F5EDD6` | Основной текст |
| `greyLight` | `#9E9E9E` | Вторичный текст, hints, captions |
| `grey` | `#6B6B6B` | Disabled, плейсхолдеры |

### Functional

| Token | HEX | Использование |
|---|---|---|
| `error` | `#CF6679` | SnackBar ошибки, error states. **Не** для бейджа "острое". |

### Запрещено

- ❌ Использовать `Colors.red`, `Colors.blue` и др. из Material
- ❌ Inline `Color(0xFF...)` — добавь в `AppColors` если нужен новый
- ❌ Прозрачность вручную: `Color(0xFFC9A84C).withOpacity(0.5)` → используй `AppColors.primary.withValues(alpha: 0.5)`
- ❌ Градиенты по умолчанию. Только в hero-секциях и баннерах акций.

---

## 📐 Spacing scale

**Кратно 4.** Других значений не существует.

```
4   xs   между иконкой и текстом
8   sm   между связанными элементами (label + input)
12  md   между элементами карточки
16  lg   стандартный padding контейнера
20  xl   padding экрана (по краям)
24  2xl  между секциями
32  3xl  большие отступы (между блоками формы)
48  4xl  hero-секции
```

Использование:
```dart
const SizedBox(height: 16),               // ✅
EdgeInsets.all(20),                        // ✅
EdgeInsets.symmetric(horizontal: 16),      // ✅

const SizedBox(height: 13),                // ❌ не в шкале
EdgeInsets.fromLTRB(20, 16, 20, 18),      // ❌ 18 не в шкале
```

---

## 🔠 Typography

Шрифты — [lib/core/theme/app_theme.dart](../lib/core/theme/app_theme.dart).

| Family | Использование |
|---|---|
| **Playfair Display** (serif) | Заголовки экранов, hero-text, ценники |
| **Inter** (sans-serif) | Body, buttons, форм, captions |

### Scale

Используй `Theme.of(context).textTheme.<style>` — не задавай fontSize/fontWeight вручную.

| Style | Размер | Когда |
|---|---|---|
| `displayLarge` | 40 | Цена в большой карточке (например, item detail) |
| `displaySmall` | 28 | Заголовок экрана, OTP-код |
| `titleLarge` | 20 | Заголовки секций формы |
| `titleMedium` | 16 | Названия блюд в карточках |
| `bodyLarge` | 16 | Основной body-текст |
| `bodyMedium` | 14 | Описания, вес |
| `bodySmall` | 12 | Captions, "Откроется WhatsApp..." |
| `labelLarge` | 14 | Текст кнопок |

### Запрещено

- ❌ `fontSize: 15` — используй scale
- ❌ Произвольное `fontWeight` без выбранного style — система уже задаёт правильный вес
- ❌ Смешивать Playfair и Inter в одной строке

---

## 🔘 Border radius scale

```
8   inputs, маленькие чипы
12  стандартные кнопки
14  карточки small (chip-like)
16  карточки контента, большие кнопки
20  модальные окна, sheet'ы
24  hero-карточки
16  FloatingCartBar (плашка корзины над BottomNav)
```

Использование:
```dart
borderRadius: BorderRadius.circular(16)   // ✅
borderRadius: BorderRadius.circular(15)   // ❌ не в шкале
```

---

## 🧩 Component patterns

### Кнопки

**ElevatedButton** — primary action (всегда одна на экране):
```dart
ElevatedButton(
  onPressed: ...,
  child: const Text('Отправить заказ'),
)
```

**ElevatedButton.icon** — primary с иконкой:
```dart
ElevatedButton.icon(
  onPressed: ...,
  icon: const Icon(Icons.send, size: 18),  // всегда 18
  label: const Text('Отправить'),
)
```

**TextButton** — secondary, "Отмена", "Изменить номер":
```dart
TextButton(onPressed: ..., child: const Text('Изменить номер'))
```

**Запрещено:**
- ❌ Несколько `ElevatedButton` на экране — выбери ОДНО главное действие
- ❌ `OutlinedButton` — у нас не используется
- ❌ Кастомные `Container` с `GestureDetector` для кнопок — используй стандартные виджеты

### Карточки

**Стандартная карточка контента:**
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
  ),
  child: ...,
)
```

**Карточка с border (для выбранного состояния):**
```dart
Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: selected ? AppColors.primary : AppColors.divider,
      width: selected ? 1.5 : 1,
    ),
  ),
)
```

### TextField

```dart
TextField(
  controller: _ctrl,
  style: const TextStyle(color: AppColors.cream),
  decoration: const InputDecoration(
    hintText: 'Подсказка',
    prefixIcon: Icon(Icons.search, color: AppColors.primary),
  ),
)
```

Базовое оформление inputs — в `AppTheme.dark` (InputDecorationTheme). Не переопределяй `border`, `fillColor` inline.

### FloatingCartBar (корзина)

Плашка в стиле Wolt/Яндекс.Еда — **над** `BottomNavigationBar`, в `MainScaffold`.

- Появляется при `cartCount > 0` (`AnimatedSize`, 300ms, `Curves.easeOutBack`)
- Фон: `AppColors.primary`, текст и иконки: `AppColors.background`
- Слева: badge с количеством; центр: `Корзина · N блюд/блюда`; справа: сумма + стрелка
- Тап → `/cart`
- Виджет: [`lib/shared/widgets/floating_cart_bar.dart`](../lib/shared/widgets/floating_cart_bar.dart)

**Не использовать** круглый FAB для корзины — перекрывает карточки меню.

### `DishImagePlaceholder`

```dart
const DishImagePlaceholder(iconSize: 48); // width/height опционально
```

Единая заглушка фото блюда. Не дублировать `Icons.restaurant` в фичах.

### Карточка блюда (`MenuItemCard`)

- Фото: `Expanded(flex: 3)`, без фото → `DishImagePlaceholder`
- Текстовый блок: `ConstrainedBox(minHeight: 80)` — название, вес, цена
- Пустая корзина: круглая кнопка `+` (`AppColors.surfaceVariant`)
- В корзине: компактный stepper `[ − qty + ]` на `AppColors.primary`, текст `AppColors.background`
- Tap по карточке → деталь; tap по stepper не открывает деталь (`HitTestBehavior.opaque`)

### `IkatPatternBackground`

```dart
IkatPatternBackground(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
  child: TextField(...),
)
```

Декоративный слой под контентом. Не вкладывать внутрь `TextField` — оборачивать блок.

### Категория (`CategoryChip`)

- Ширина **96**, иконка **80×80**, арка `24` сверху / `16` снизу
- Рамка: `accentBlue` @ 35% opacity; иконка `primary`
- Название: `maxLines: 2`, `ellipsis`, `height: 1.2`
- Иконка: `CategoryChip.iconForCategory(name)` — статический хелпер

### Статус ресторана (`ShopStatusBadge`)

- Открыто: точка `AppColors.halal`, подпись `AppColors.greyLight`
- Закрыто / скоро закроется: `AppColors.error` / `AppColors.primary`

### SnackBar

**Только два сценария**, других быть не должно:

```dart
// Ошибка
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(msg), backgroundColor: AppColors.error),
);

// Успех
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(msg), backgroundColor: AppColors.halal),
);
```

### Бейджи

```dart
// Halal
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.halal,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text('Халяль',
    style: TextStyle(color: AppColors.cream, fontSize: 11)),
)

// Spicy
Container(
  // та же структура, color: AppColors.spicy, text: 'Острое'
)
```

---

## 🎬 Анимации

**Длительности:**
- `100ms` — micro-interactions (ripple, hover)
- `200ms` — стандартные переходы состояний (выбор/невыбор кнопки)
- `300ms` — modal'ы, переходы экранов
- `500ms+` — только для hero-анимаций

**Easing:**
- По умолчанию `Curves.easeInOut`
- Для появления — `Curves.easeOut`
- Для исчезновения — `Curves.easeIn`

**AnimatedContainer** — стандартный способ анимировать смену состояния:
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  decoration: BoxDecoration(...),
  child: ...,
)
```

---

## 📱 Layout правила

### Стандартная структура экрана

```dart
Scaffold(
  appBar: AppBar(title: const Text('Заголовок')),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),  // 20 ВСЕГДА для краёв экрана
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // секции через _sectionTitle + контент
        // между секциями: SizedBox(height: 24)
      ],
    ),
  ),
)
```

### Safe area

`SafeArea` автоматически в `Scaffold`, дополнительно оборачивать **только** `bottomNavigationBar`:

```dart
bottomNavigationBar: SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: ElevatedButton(...),
  ),
)
```

### Sticky footer (кнопка снизу всегда)

```dart
Scaffold(
  body: SingleChildScrollView(...),
  bottomNavigationBar: SafeArea(child: ...),  // не floatingActionButton для CTA
)
```

---

## ✍️ Тон коммуникации

- **Русский язык, "вы"-форма.** Никаких "ты".
- **Короткие фразы.** "Заказ отправлен", а не "Ваш заказ был успешно отправлен".
- **Без emoji в UI** (кроме WhatsApp-сообщений, где они служебные).
- **Деньги** — всегда в тенге, с разделителем тысяч: `5 000 тг` (пробел между тысячами, "тг" в нижнем регистре).
- **Время** — `13:00`, не `13:00:00` и не `1 PM`.
- **Дата** — `20 мая, среда` для отображения, `dd.MM.yyyy` для технических полей.

---

## 📱 Навигация и корзина

| Элемент | Поведение |
|---|---|
| `BottomNavigationBar` | Вкладки «Меню» (`/`) и «Бронь» (`/reservation`) |
| `FloatingCartBar` | Над нижним меню; видна только при `cartCount > 0` |
| CTA на формах | `bottomNavigationBar: SafeArea` — не `floatingActionButton` |

Подробнее по экранам → [features.md](features.md).

---

## 🚫 Anti-patterns — никогда

1. ❌ Material Banner / Material AlertDialog в стандартном стиле — выпадают из палитры
2. ❌ `Theme.of(context).colorScheme.primary` — пиши явно `AppColors.primary`
3. ❌ Произвольные shadows — мы в dark theme, shadows почти не видны
4. ❌ `IconData` мимо `Icons.*` — только Material Icons, никаких кастомных SVG в widgets
5. ❌ Bright accent colors (синий, фиолетовый, неон) — не наш язык
6. ❌ Skeumorphism (3D, градиенты с тенями) — мы flat + золото-акцент
7. ❌ Light theme — у нас только dark
8. ❌ Гифки, лоттие-анимации — только статика и нативные transitions
9. ❌ Плейсхолдеры «вилка и нож» / generic `Icons.restaurant` на блюдах — только узбекская посуда (казан, лягана, пиала)
10. ❌ Пёстрый «чайханный» UI — этнические акценты дозированно (один доп. цвет, паттерн 3–5% opacity)
