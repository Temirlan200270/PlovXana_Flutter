# Настройка Supabase

## ✅ Статус: проект создан и настроен

| Параметр | Значение |
|---|---|
| Project URL | `https://dvmkxopjbwozgbckumdm.supabase.co` |
| Project Ref | `dvmkxopjbwozgbckumdm` |
| Region | `eu-central-1` |
| Статус | `ACTIVE_HEALTHY` |

Credentials — в [.env](../.env). Схема задеплоена через `supabase/migrations/`.

---

## Что осталось настроить

### Phone Auth (SMS-провайдер)

Авторизация по телефону (OTP) требует SMS-провайдера.

**Dashboard → Authentication → Providers → Phone → Enable**

#### Twilio (рекомендуется)

1. Создать аккаунт [twilio.com](https://www.twilio.com) → получить номер
2. В Supabase Dashboard заполнить:
   - **SMS Provider:** Twilio
   - **Account SID:** из Twilio Console
   - **Auth Token:** из Twilio Console
   - **From Number** или **Message Service SID**
3. OTP Expiry: 300 секунд

#### Тестовый режим (без реального SMS)

Dashboard → Authentication → Phone → **Phone Confirm** → добавить тестовый номер с фиксированным кодом. Удобно при разработке.

---

### Storage (фотографии блюд)

1. **Storage → Create bucket** → имя: `menu`, тип: **Public**
2. Загрузить фото блюд
3. Копировать публичный URL в `image_url` вручную в таблице `menu_items` (или через SQL). Hourly iiko-sync **не затирает** ручные URL, если в iiko нет фото — см. [iiko-sync.md](iiko-sync.md#фотографии-блюд-image_url)

Формат URL:
```
https://dvmkxopjbwozgbckumdm.supabase.co/storage/v1/object/public/menu/filename.jpg
```

---

## Схема БД (задеплоена)

Таблицы: `categories`, `menu_items`, `promotions`, `orders`, `reservations`

Добавлены колонки `iiko_id uuid UNIQUE` для синхронизации с iiko.

Подробнее → [data-models.md](data-models.md)

---

## Миграции

Новые миграции — в `supabase/migrations/YYYYMMDDHHMMSS_name.sql`.  
Применяются автоматически при push в `main` через GitHub Actions.

```bash
# Ручное применение (локально):
supabase db push --project-ref dvmkxopjbwozgbckumdm --password $SUPABASE_DB_PASSWORD
```

---

## GitHub Actions (CI/CD)

Два workflow в `.github/workflows/`. Секреты задаются в **Settings → Secrets and variables → Actions**.

### `db_migrate.yml` — миграции при push в `main`

| Тип | Имя | Назначение |
|---|---|---|
| **Variable** | `SUPABASE_PROJECT_REF` | Ref проекта (`dvmkxopjbwozgbckumdm`) |
| **Secret** | `SUPABASE_ACCESS_TOKEN` | [Account → Access Tokens](https://supabase.com/dashboard/account/tokens) |
| **Secret** | `SUPABASE_DB_PASSWORD` | Dashboard → Settings → Database → Database password |

### `iiko_sync.yml` — меню и стоп-листы (каждый час)

| Secret | Назначение |
|---|---|
| `SUPABASE_URL` | Project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | `service_role` key |
| `IIKO_API_LOGIN` | Логин API iiko |
| `IIKO_ORGANIZATION_ID` | UUID организации |
| `IIKO_TERMINAL_GROUP_ID` | Опционально, для stop list |

Подробности, локальный запуск и troubleshooting → [iiko-sync.md](iiko-sync.md).

---

## RLS-политики (задеплоены)

| Таблица | Операция | Условие |
|---|---|---|
| `categories` | SELECT | все (публично) |
| `menu_items` | SELECT | все (публично) |
| `promotions` | SELECT | все (публично) |
| `orders` | INSERT / SELECT | `auth.uid() = user_id` |
| `reservations` | INSERT | все (гости тоже могут) |
| `reservations` | SELECT | `auth.uid() = user_id OR user_id IS NULL` |
