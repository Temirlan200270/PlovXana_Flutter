# ПЛОВ НОМЕР 1 — Мобильное приложение

Официальное Flutter-приложение ресторана узбекской кухни.  
Меню, корзина, оформление заказа через WhatsApp, бронирование столов, авторизация по SMS.

---

## Быстрый старт

```bash
flutter pub get
flutter run
```

Supabase подключён, схема задеплоена, iiko-синхронизация настроена.

---

## iiko → Supabase синхронизация меню

```bash
cd scripts/iiko_sync
pip install -r requirements.txt

python sync.py menu    # категории + блюда
python sync.py stop    # стоп-листы (is_available)
python sync.py all     # всё сразу
```

Автоматически раз в час через GitHub Actions (`.github/workflows/iiko_sync.yml`).

---

## Миграции БД

```bash
# Новую миграцию добавить в supabase/migrations/
# Применяется автоматически при push в main → .github/workflows/db_migrate.yml
```

---

## Документация

| Документ | Описание |
|---|---|
| [docs/roadmap.md](docs/roadmap.md) | Что сделано и что дальше |
| [docs/architecture.md](docs/architecture.md) | Структура проекта, стек, навигация, провайдеры |
| [docs/design-system.md](docs/design-system.md) | Цвета, типографика, spacing, компоненты |
| [docs/features.md](docs/features.md) | Описание всех экранов |
| [docs/data-models.md](docs/data-models.md) | Модели данных, схема БД, RLS |
| [docs/supabase-setup.md](docs/supabase-setup.md) | Настройка Phone Auth / SMS-провайдера |

---

## Стек

| Слой | Технология |
|---|---|
| Mobile | Flutter 3.41 / Dart 3.11 |
| State | Riverpod 2.6 |
| Navigation | GoRouter 14 |
| Backend | Supabase (PostgreSQL + Auth) |
| Menu sync | iiko Cloud API v1 → Python |
| Orders | WhatsApp (`wa.me/77074007728`) |
| CI/CD | GitHub Actions |
| Fonts | Playfair Display + Inter |

## MCP-стек (Claude Code)

| Server | Назначение |
|---|---|
| `dart-flutter` | analyze, format, hot reload, screenshots |
| `marionette` | runtime UI interaction (tap, scroll, screenshot) |
| `supabase` | schema, SQL, table data |
| `agent-browser` | браузерная автоматизация |
