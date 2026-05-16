# PlovХана — Мобильное приложение

Официальное Flutter-приложение ресторана узбекской кухни.  
Меню, корзина, оформление заказа через WhatsApp, бронирование столов, авторизация по SMS.

---

## Быстрый старт

```bash
flutter pub get
flutter run
```

Старт приложения: `/splash` (~2 с) → главная.  
Нижняя навигация: **Меню** · **Бронь** · **Профиль**.  
Supabase подключён, схема задеплоена, iiko-синхронизация настроена.

---

## iiko → Supabase синхронизация меню

Переменные — в `.env` в корне (см. `.env.example`). Подробно: [docs/iiko-sync.md](docs/iiko-sync.md).

```bash
cd scripts/iiko_sync
pip install -r requirements.txt

python sync.py orgs    # UUID организации для IIKO_ORGANIZATION_ID
python sync.py menu    # категории + блюда
python sync.py stop    # стоп-листы (is_available)
python sync.py all     # всё сразу
```

**CI:** workflow `.github/workflows/iiko_sync.yml` (каждый час + ручной запуск).  
Нужны GitHub **Repository secrets**: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `IIKO_API_LOGIN`, `IIKO_ORGANIZATION_ID` (и опционально `IIKO_TERMINAL_GROUP_ID`). Без них CI падает с `Missing required env var`.

Ручные фото в `menu_items.image_url` **не затираются** sync, если в iiko нет картинки.

---

## Корзина (UX)

На вкладках «Меню» и «Бронь» над нижней навигацией — золотая плашка **FloatingCartBar** (появляется после первого `+` в меню): количество, сумма, переход в `/cart`.

## Дизайн (Premium Uzbek)

Тёмный splash, золото + лазурь `accentBlue`, казан-заглушки, икат-паттерн, арочные категории — [docs/design-system.md](docs/design-system.md).

## Доставка (Павлодар)

Константы в `lib/core/config/app_config.dart`, расчёт в `delivery_rules.dart`:

| Параметр | Значение |
|---|---|
| Стоимость | 700 тг |
| Бесплатно от | 10 000 тг (сумма блюд) |
| Минимум доставки | 3 000 тг (сумма блюд) |
| Приём заказов | 11:00–22:45 |
| Время | 45–75 мин |
| Зона | весь Павлодар |

Плашка + sheet на главной; в checkout — разбивка «Сумма блюд / Доставка / Итого».  
API: `AppConfig`, `delivery_rules`, `user_prefs`, виджеты — [docs/architecture.md](docs/architecture.md#appconfig).  
Подробно — [docs/features.md](docs/features.md).

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
| [docs/roadmap.md](docs/roadmap.md) | Roadmap + **что критично до первого клиента** |
| [docs/architecture.md](docs/architecture.md) | Структура проекта, стек, навигация, провайдеры |
| [docs/design-system.md](docs/design-system.md) | Цвета, типографика, Premium Uzbek, компоненты |
| [docs/features.md](docs/features.md) | Экраны, провайдеры меню, доставка, корзина |
| [docs/data-models.md](docs/data-models.md) | Модели данных, схема БД, RLS |
| [docs/supabase-setup.md](docs/supabase-setup.md) | Настройка Phone Auth / SMS-провайдера, CI secrets |
| [docs/iiko-sync.md](docs/iiko-sync.md) | Синхронизация меню iiko, локальный запуск, GitHub Actions |

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
| E2E (dev) | [Patrol](https://patrol.leancode.co/) (`dev_dependencies`, см. `pubspec.yaml`) |

### Smoke-тесты (Patrol)

```bash
patrol test --target integration_test/smoke_test.dart
```

Сценарии: splash («ПЛОВ НОМЕР 1»), три вкладки BottomNav, переход на «Бронь». Подробнее — [docs/architecture.md](docs/architecture.md#тестирование-patrol).

## MCP-стек (Claude Code)

| Server | Назначение |
|---|---|
| `dart-flutter` | analyze, format, hot reload, screenshots |
| `marionette` | runtime UI interaction (tap, scroll, screenshot) |
| `supabase` | schema, SQL, table data |
| `agent-browser` | браузерная автоматизация |
