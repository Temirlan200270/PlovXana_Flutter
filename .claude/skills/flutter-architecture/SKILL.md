---
name: flutter-architecture
description: Use when creating new features, screens, or refactoring. Defines folder structure, separation of concerns, and file organization rules for the plovxana Flutter project.
---

# Flutter Architecture — plovxana

## Folder structure

```
lib/
├── main.dart                  # Bootstrap only — никакой бизнес-логики
├── core/                      # Cross-cutting concerns
│   ├── theme/                 # Colors, theme data, typography
│   ├── router/                # GoRouter config
│   └── supabase/              # Supabase client config
├── shared/                    # Reusable across features
│   ├── models/                # Domain models (Equatable)
│   └── widgets/               # Cross-feature widgets (MainScaffold, etc.)
└── features/<feature>/        # Self-contained feature module
    ├── data/                  # Providers, repositories, API calls
    └── presentation/
        ├── screens/           # Full-page widgets (route targets)
        └── widgets/           # Feature-specific reusable widgets
```

## Hard rules

### Rule 1 — Feature isolation

Каждая фича — самостоятельный модуль. Фича `cart` не импортирует ничего из `features/menu/`. Только из `shared/` и `core/`.

**Если двум фичам нужен один и тот же виджет** → выносим в `shared/widgets/`.

### Rule 2 — Один экран = один файл

Файл `home_screen.dart` содержит **только** `HomeScreen` (и его State, если нужен).

Вспомогательные виджеты:
- Используется в одном месте → private класс в том же файле (`class _ItemTile`)
- Используется в нескольких местах внутри фичи → отдельный файл в `features/<f>/presentation/widgets/`
- Используется в разных фичах → `shared/widgets/`

### Rule 3 — Размер файла

- Экран > 300 строк — разбить на виджеты
- Виджет > 150 строк — разбить
- Метод build > 80 строк — разбить

### Rule 4 — Зависимости между слоями

```
presentation → data → shared/models
     ↓           ↓
   (можно)   shared/models
```

- `presentation/` импортирует `data/` (через ref.watch провайдеров)
- `data/` импортирует `shared/models/`
- `shared/models/` ничего не импортирует из проекта (только packages)
- `presentation/` НЕ обращается к Supabase напрямую — только через провайдеры в `data/`

### Rule 5 — Naming

| Что | Pattern | Пример |
|---|---|---|
| Экран | `<Name>Screen` | `CheckoutScreen` |
| Виджет фичи | `<Name>` (без Widget) | `MenuItemCard` |
| Провайдер state | `<name>Provider` | `cartProvider` |
| Provider данных | `<name>sProvider` (мн.ч.) | `categoriesProvider` |
| Модель | `<Name>` (PascalCase) | `MenuItem` |
| Файл | `snake_case.dart` | `menu_item_card.dart` |

## Creating a new feature

Пример: добавляем `favorites` (избранное).

```
features/favorites/
├── data/
│   └── favorites_provider.dart    # StateNotifierProvider<List<String>>
└── presentation/
    ├── screens/
    │   └── favorites_screen.dart
    └── widgets/
        └── favorite_button.dart
```

Затем:

1. **Маршрут** в [lib/core/router/app_router.dart](../../../lib/core/router/app_router.dart):
   ```dart
   GoRoute(path: '/favorites', builder: (c, s) => const FavoritesScreen())
   ```

2. **Точка входа** — кнопка/иконка в `MainScaffold` или другом экране.

3. **Persistence** (если нужна) — `shared_preferences` (уже в зависимостях).

## Anti-patterns — НЕ ДЕЛАТЬ

- ❌ Бизнес-логика в `main.dart`
- ❌ Прямой вызов `Supabase.instance.client` из экрана (только через провайдер)
- ❌ `setState` для данных, которые нужны другому экрану
- ❌ Файл `utils.dart` со случайными функциями — каждая утилита должна иметь явное место
- ❌ Глобальные singleton'ы вне Riverpod
- ❌ `BuildContext` в `data/` слое
