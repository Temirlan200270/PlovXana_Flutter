# Design System — ПЛОВ НОМЕР 1

Централизованные UI-правила. **Любое отклонение требует явного решения**, а не вкусовщины.

## Дизайн-философия

**Premium Eastern.** Тёмная база (как ночной ресторан), золото-акцент (как лампы и медь), кремовая типографика (как тёплый свет на скатерти).

Это **не Material Design** в чистом виде. Не **Cupertino**. Это собственный язык, заточенный под узбекскую кухню в дорогом сегменте.

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

### Карточка блюда (`MenuItemCard`)

- Фото: `Expanded(flex: 3)`, плейсхолдер `Icons.restaurant`
- Текстовый блок: `ConstrainedBox(minHeight: 80)` — название, вес, цена
- Пустая корзина: круглая кнопка `+` (`AppColors.surfaceVariant`)
- В корзине: компактный stepper `[ − qty + ]` на `AppColors.primary`, текст `AppColors.background`
- Tap по карточке → деталь; tap по stepper не открывает деталь (`HitTestBehavior.opaque`)

### Категория (`CategoryChip`)

- Ширина чипа: **96**, иконка 64×64
- Название: `maxLines: 2`, `TextOverflow.ellipsis`, `textAlign: center`

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
