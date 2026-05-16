# ПЛОВ НОМЕР 1 — Project Rules

Flutter-приложение ресторана узбекской кухни. Меню, корзина, заказ через WhatsApp, бронирование, SMS-авторизация.

## Stack

- Flutter 3.41 / Dart 3.11
- Riverpod 2.6 (state)
- GoRouter 14 (navigation)
- Supabase (backend + auth)
- WhatsApp (order delivery)

## Hard rules

1. **Архитектура — `features/<name>/{data,presentation}`**. Подробности → `.claude/skills/flutter-architecture/SKILL.md`
2. **State — только через Riverpod**. Никаких `setState` для бизнес-логики. Подробности → `.claude/skills/riverpod-patterns/SKILL.md`
3. **Дизайн-токены — только из `lib/core/theme/app_colors.dart`**. Никаких inline `Color(0xFF...)` в widget-коде. Подробности → `docs/design-system.md`
4. **Spacing — кратно 4 (4, 8, 12, 16, 20, 24, 32, 48)**. Никаких 5, 7, 13, 17 и т.п.
5. **UI-тексты — через `AppLocalizations` (ru + kk)**. Меню из Supabase не переводится. Цены — целые числа в тенге.
6. **Перед коммитом — `flutter analyze` должен показывать 0 ошибок.**

## Workflow for new features

1. Прочитай `docs/architecture.md` чтобы понять, куда положить код
2. Создай модель в `lib/shared/models/` если нужна
3. Создай провайдер в `features/<f>/data/`
4. Создай экран в `features/<f>/presentation/screens/`
5. Добавь маршрут в `lib/core/router/app_router.dart`
6. Запусти `flutter analyze` — должно быть чисто

## Workflow for UI changes

1. Подключись к Marionette MCP (если приложение запущено)
2. Сделай screenshot текущего состояния
3. Внеси изменения
4. Hot reload через Dart/Flutter MCP
5. Сделай screenshot и сравни
6. Подробности → `.claude/skills/ui-test-loop/SKILL.md`

## Available skills

| Skill | Когда использовать |
|---|---|
| `flutter-architecture` | Создание новой фичи / экрана |
| `riverpod-patterns` | Любая работа со state |
| `ui-screen-generator` | Скаффолдинг нового экрана |
| `api-integration` | Подключение Supabase-таблицы |
| `debug-ui` | UI баги, layout-проблемы |
| `ui-test-loop` | Self-healing UI workflow |

## Available MCP servers

| Server | Когда использовать |
|---|---|
| `dart-flutter` | analyze, format, pub, hot restart, screenshots |
| `marionette` | Tap, scroll, input, widget tree — требует запущенного приложения |
| `supabase` | Schema, SQL, table data — требует access token |

## Don't

- Не создавай `*.md` файлы документации, кроме как по явной просьбе
- Не добавляй комментарии в код, объясняющие очевидное
- Не использовай `Color(0xFF...)` в widget-коде — только через `AppColors`
- Не пиши widget-tests без явной просьбы
- Не предлагай Firebase / другие BaaS — у нас Supabase
- Не предлагай BLoC / Provider / GetX — у нас Riverpod
