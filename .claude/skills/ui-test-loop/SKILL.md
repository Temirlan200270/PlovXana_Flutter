---
name: ui-test-loop
description: Use for self-healing UI workflow - generating a screen, visually verifying it via Marionette screenshots, and iterating until correct without leaving the conversation.
---

# UI Test Loop — Self-healing UI

## Концепция

Замкнутый цикл, где Claude:
1. Генерирует UI-код
2. Видит результат через screenshot
3. Сам ловит баги
4. Исправляет
5. Подтверждает фикс новым screenshot'ом

Без участия человека на промежуточных шагах.

## Когда применять

| Применяй | Не применяй |
|---|---|
| Новый экран по описанию | Просто рефакторинг |
| "Сделай как на скриншоте N" | Бизнес-логика без UI |
| Баг с layout | Баг в state-логике (используй `debug-ui` + flutter logs) |
| Pixel-perfect доводка | Производительность |

## Pre-flight checklist

Перед запуском цикла убедись:

- [ ] Приложение запущено: `flutter run` (видна VM URI)
- [ ] Marionette MCP активен: `dart run marionette_mcp` запущен в другом терминале
- [ ] Claude подключён к Marionette (один раз за сессию)
- [ ] Hot reload работает (изменения применяются без перезапуска)

## Полный цикл

### Шаг 1 — Snapshot baseline

```
Marionette → screenshot
Marionette → widget_tree
```

Это нужно чтобы знать стартовую точку.

### Шаг 2 — Generate / Edit

Внеси изменения в код через Edit-инструменты. Не нужно build/run — hot reload подхватит.

### Шаг 3 — Hot reload

Через Dart/Flutter MCP:
```
dart-flutter → hot_reload
```

Или Marionette:
```
marionette → hot_reload
```

### Шаг 4 — Verify

```
marionette → screenshot
```

Сравни с тем, что ожидалось. Если есть видимая проблема — диагностируй через `debug-ui` skill.

### Шаг 5 — Iterate

Если не идеально:
- Прочитай widget_tree вокруг проблемного места
- Сформулируй конкретную гипотезу (одну, не три)
- Внеси одно изменение
- Hot reload + screenshot
- Repeat

**Лимит:** максимум 5 итераций. После пятой — остановись, сформулируй что не получается, спроси пользователя.

## Decision tree: что фиксить

```
Screenshot показывает проблему?
├── Overflow / RenderFlex error
│   → debug-ui skill, секция "RenderFlex overflowed"
├── Контент за пределами viewport
│   → проверь padding снизу под BottomNav
├── Цвет неправильный
│   → проверь импорт AppColors, не используй inline Color(...)
├── Текст обрезан / пустой
│   → maxLines? overflow? color на фоне?
├── Tap не реагирует
│   → GestureDetector / IgnorePointer / Stack-перекрытия
├── Spacing выглядит "криво"
│   → проверь scale 4/8/12/16/20/24/32 (ui-screen-generator)
└── Алайнмент off
    → MainAxis/CrossAxis в Row/Column
```

## Пример сессии

**User:** Сделай экран профиля пользователя — аватар, имя, телефон, кнопка "Выйти".

**Claude:**
1. Read `app_router.dart` — где добавить маршрут
2. Read `auth_screen.dart` — как работает текущая авторизация
3. Создать `lib/features/profile/presentation/screens/profile_screen.dart`
4. Добавить маршрут `/profile`
5. Добавить точку входа (например, иконка в AppBar главной)
6. **Marionette → screenshot** (главная)
7. **Marionette → tap(key: 'profile-button')**
8. **Marionette → screenshot** (новый экран)
9. Проверить: видны ли все элементы, нет ли overflow
10. Если ОК — задача решена
11. Если не ОК — диагностика через debug-ui, фикс, hot_reload, новый screenshot

## Когда break loop и спросить пользователя

- 5+ итераций без приближения к цели
- Требуется ввод данных (текст, цвет, изображение), которого нет в задаче
- Изменение архитектурно (затрагивает несколько экранов) — нужно подтверждение
- Marionette не подключается / hot reload не работает

## Что НЕ делать в этом цикле

- ❌ Делать `flutter run` заново — используй hot reload
- ❌ Менять архитектуру (выносить виджет, переносить файл) во время визуальных фиксов
- ❌ Комитить промежуточные итерации
- ❌ Игнорировать flutter analyze warnings — они часто и есть причина проблемы
- ❌ Делать screenshot после каждого мелкого изменения — батч 2-3 правки, потом screenshot

## Output после успешного цикла

В одном сообщении пользователю:
1. Что было сделано (1-2 предложения)
2. Сколько итераций потребовалось
3. Финальный screenshot (если возможно показать)
4. Что осталось (если есть нюансы)

Без перечисления промежуточных шагов и без длинных summary.
