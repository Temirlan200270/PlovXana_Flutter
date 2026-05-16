# iiko → Supabase: синхронизация меню

Скрипт `scripts/iiko_sync/sync.py` загружает категории и блюда из iiko Cloud API в Supabase и обновляет стоп-листы (`is_available`).

---

## Локальный запуск

### 1. Переменные окружения

Скопируйте [.env.example](../.env.example) в `.env` в **корне проекта** и заполните блоки iiko и Supabase:

```env
IIKO_API_LOGIN=...
IIKO_ORGANIZATION_ID=...
IIKO_TERMINAL_GROUP_ID=          # необязательно (для stop list)

SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...    # Dashboard → Settings → API → service_role
```

`sync.py` читает `.env` из корня репозитория (`load_dotenv`). Файл `.env` в git не попадает.

Шаблон только для iiko: [scripts/iiko_sync/.env.iiko.example](../scripts/iiko_sync/.env.iiko.example).

### 2. Установка и команды

```bash
cd scripts/iiko_sync
pip install -r requirements.txt

python sync.py orgs    # список организаций iiko → скопировать UUID в IIKO_ORGANIZATION_ID
python sync.py menu    # категории + блюда
python sync.py stop    # стоп-листы (is_available)
python sync.py all     # menu + stop
```

`SUPABASE_SERVICE_ROLE_KEY` обходит RLS — используйте только локально и в CI, не в Flutter-приложении.

### Фотографии блюд (`image_url`)

В iiko у большинства позиций нет `imageLinks`. Фото обычно заливают вручную в Supabase (Storage → `image_url` в `menu_items`).

**Поведение `menu_sync.py`:** при upsert берётся фото из iiko; если в iiko пусто — **сохраняется** уже существующий `image_url` из Supabase. Ручные ссылки не затираются при hourly sync.

Если в iiko появится своё фото — оно перезапишет ручное (приоритет у iiko).

Реализация: `_async_sync_menu` в [`menu_sync.py`](../scripts/iiko_sync/menu_sync.py) — словарь `existing_images` до цикла upsert.

---

## GitHub Actions

Workflow: [.github/workflows/iiko_sync.yml](../.github/workflows/iiko_sync.yml)

| Триггер | Действие |
|---|---|
| `cron: 0 * * * *` | Синхронизация каждый час |
| `workflow_dispatch` | Ручной запуск: Actions → **iiko → Supabase sync** → Run workflow |

### Secrets (обязательно)

**Settings → Secrets and variables → Actions → Repository secrets**

Имена должны совпадать **точно** (регистр важен):

| Secret | Где взять |
|---|---|
| `SUPABASE_URL` | Supabase Dashboard → Settings → API → Project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Тот же раздел → `service_role` (secret) |
| `IIKO_API_LOGIN` | Логин API iiko Cloud |
| `IIKO_ORGANIZATION_ID` | UUID организации (`python sync.py orgs`) |
| `IIKO_TERMINAL_GROUP_ID` | UUID терминальной группы (опционально; нужен для шага stop list) |

Без этих secrets шаг **Sync menu** падает с ошибкой:

```text
Missing required env var: SUPABASE_URL
```

В логе CI переменные будут пустыми — это нормальный признак того, что secrets не заданы (GitHub не показывает значения secrets в логах).

### После добавления secrets

1. Actions → **iiko → Supabase sync** → **Re-run all jobs**
2. Убедиться, что оба шага (**Sync menu**, **Sync stop lists**) завершились зелёным

---

## Частые проблемы

| Симптом | Причина | Решение |
|---|---|---|
| `Missing required env var: SUPABASE_URL` в CI | Secrets не созданы или имя не совпадает | Добавить secrets по таблице выше |
| Локально работает, в CI — нет | В CI нет файла `.env` | Только repository secrets, не `.env` |
| Secrets пустые при PR из fork | GitHub не отдаёт secrets форкам | Запускать workflow в основном репозитории |
| Secrets в Environment, а не в repo | Workflow не указывает `environment:` | Добавить secrets на уровне репозитория или прописать `environment` в YAML |

---

## Связанные workflow

Миграции БД: [.github/workflows/db_migrate.yml](../.github/workflows/db_migrate.yml) — отдельные secrets/vars, см. [supabase-setup.md](supabase-setup.md#github-actions-cicd).
