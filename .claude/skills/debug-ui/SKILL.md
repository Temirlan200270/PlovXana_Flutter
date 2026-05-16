---
name: debug-ui
description: Use when fixing layout bugs, overflow errors, alignment issues, or visual regressions. Defines the screenshot-first debugging workflow using Marionette MCP.
---

# Debug UI Layout — Marionette workflow

## Принцип: Screenshot first

**Не угадывай — посмотри.** Перед любым layout-фиксом сделай screenshot через Marionette MCP. Большинство UI-багов очевидны на скриншоте за 2 секунды и невидимы в коде.

## Стандартный debug-цикл

```
1. Запустить приложение в debug-режиме (если не запущено)
   → flutter run
2. Запустить Marionette MCP
   → dart run marionette_mcp
3. В чате: "подключись к приложению"
4. Сделать screenshot текущего состояния (или конкретного экрана)
5. Прочитать widget tree вокруг проблемного места
6. Сформулировать гипотезу
7. Внести изменение
8. Hot reload через Dart/Flutter MCP (или auto при сохранении)
9. Сделать screenshot снова
10. Сравнить — задача решена?
```

## Типичные баги и быстрая диагностика

### "RenderFlex overflowed by N pixels"

**Где:** `Row` или `Column` без констрейнтов  
**Что искать в tree:** `Row` с `Text` внутри без `Expanded` / `Flexible`  
**Фикс:**
```dart
// ❌
Row(children: [Text('Длинное название блюда'), Icon(...)])

// ✅
Row(children: [
  Expanded(child: Text('Длинное название блюда', overflow: TextOverflow.ellipsis)),
  Icon(...),
])
```

### "BoxConstraints forces an infinite height"

**Где:** `Column` внутри `Column` без `Expanded` или `ListView` внутри `Column` без bounded height  
**Фикс:**
```dart
// ❌
Column(children: [SomeWidget(), ListView(...)])

// ✅
Column(children: [SomeWidget(), Expanded(child: ListView(...))])
```

### Текст обрезается или невидим

**Симптомы:** ничего не видно или показывается `...`  
**Что проверить:**
1. Цвет текста — в dark theme `Color(0xFF1A1A1A)` на background = невидимо
2. `maxLines` слишком маленький
3. `overflow: TextOverflow.ellipsis` без `maxLines`

**Правило:** в plovxana всегда `color: AppColors.cream` для основного текста, `AppColors.greyLight` для вторичного.

### Изображение не загружается

**Что проверить:**
1. URL валидный (открой в браузере)
2. `cached_network_image` — обработан ли `errorWidget`?
3. Bucket в Supabase Storage публичный?

```dart
CachedNetworkImage(
  imageUrl: item.imageUrl ?? '',
  fit: BoxFit.cover,
  placeholder: (_, __) => Container(color: AppColors.surface),
  errorWidget: (_, __, ___) => Icon(Icons.image_not_supported, color: AppColors.grey),
)
```

### Touch-target не реагирует

**Что проверить:**
1. Виджет завёрнут в `GestureDetector` / `InkWell` / `IconButton`?
2. `onTap` — null или функция?
3. Поверх него нет другого виджета? (используй Flutter Inspector через Marionette tree)
4. `IgnorePointer` / `AbsorbPointer` в родителях?

### BottomNav / FAB перекрывают контент

**Фикс:**
```dart
// ✅ Добавь padding снизу = высота nav + safe area
SingleChildScrollView(
  padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom + 80),
  child: ...,
)

// Или используй SliverFillRemaining + Padding
```

## Marionette commands

После `dart run marionette_mcp` и подключения, можно:

| Команда | Что делает |
|---|---|
| `screenshot` | PNG всего экрана |
| `widget_tree` | Дерево виджетов (semantic snapshot) |
| `tap(text: '...')` или `tap(key: '...')` | Симулировать тап |
| `enter_text(...)` | Ввести в TextField |
| `scroll(...)` | Скроллить |
| `hot_reload` | Применить изменения в коде |

## Когда менять `MainAxisAlignment` / `crossAxisAlignment`

```
Row / Column:
  mainAxisAlignment   = вдоль главной оси (Row=горизонталь, Column=вертикаль)
  crossAxisAlignment  = поперёк
  mainAxisSize        = занимать всё пространство или только нужное

Самые частые ошибки:
  Column без mainAxisAlignment.center → контент сверху
  Row с двумя Expanded — всегда заполнит, не нужен mainAxisAlignment
  CrossAxisAlignment.stretch — растянет детей по поперечной оси
```

## Debug overlay (если Marionette недоступен)

Включить визуальные констрейнты:

```dart
// В main.dart, только debug
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;       // размеры всех виджетов
  debugPaintBaselinesEnabled = true;  // baseline текста
  // ...
}
```

Не коммить — только локально.

## Anti-patterns

- ❌ Угадывать причину overflow без скриншота
- ❌ Оборачивать всё в `SingleChildScrollView` "на всякий случай" — это часто скрывает реальный баг
- ❌ Магические `SizedBox(height: 100)` без понимания layout-системы
- ❌ Использовать `MediaQuery.of(context).size.height * 0.X` для размеров — ломается на разных устройствах
- ❌ `Stack` там, где работает `Column` — Stack делает touch-targets непредсказуемыми
