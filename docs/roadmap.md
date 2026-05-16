# Roadmap — ПЛОВ НОМЕР 1

## Продуктовая оценка перед запуском

Честная картина: MVP готов технически, но до первых **реальных** клиентов не хватает нескольких вещей, которые пользователь сразу заметит.

### Критично до первого клиента

| Задача | Статус в коде | Почему важно |
|---|---|---|
| **История заказов** | `INSERT` в `orders` есть ([`checkout_screen.dart`](../lib/features/checkout/presentation/checkout_screen.dart)); экрана **нет** — только `ProfileScreen` без списка | После заказа пользователь не видит, что произошло. Данные в Supabase уже есть, RLS `orders_select_own` настроен ([data-models.md](data-models.md)) |
| **App icon** | Дефолтный Flutter-значок | Перед раздачей APK людям нужен бренд (плов / золото на тёмном фоне) |
| **Release APK** | `flutter build apk --release` без keystore → debug-подпись | На части устройств APK не установится; нужен release keystore + подпись |

### Важно, но не блокирует запуск

| Задача | Статус | Комментарий |
|---|---|---|
| Модификаторы блюд | Нет | В iiko есть «острый / без лука / большая порция»; сейчас только комментарий в checkout |
| Сохранение корзины | In-memory ([`cart_provider.dart`](../lib/features/cart/data/cart_provider.dart)) | Закрыл приложение — корзина пустая; можно через `shared_preferences` (инфраструктура уже есть в `user_prefs`) |
| Онлайн-оплата (Kaspi) | Нет | В KZ мастхэв для конкуренции; Kaspi QR/Pay API |
| Зоны доставки | «Весь Павлодар» без проверки | Нет валидации адреса / района до звонка менеджера |

### Технический долг

| Задача | Статус | Комментарий |
|---|---|---|
| Crash reporting (Sentry) | Нет в `pubspec.yaml` | Без него крэши у реальных пользователей не видны |
| Offline fallback | Нет | При потере сети — спиннеры; нужен кеш меню локально |
| Deep links | Частично | `/item/:id` без `extra` → редирект на `/`; поделиться блюдом ссылкой нельзя |

### Хорошо иметь (Phase 2–3)

Отзывы и рейтинги, избранное, промокоды, push-уведомления, повторный заказ из истории, отслеживание статуса заказа, казахский язык.

---

### Рекомендуемые приоритеты

**Цель: APK первым клиентам в ближайшие дни**

1. App icon  
2. История заказов (чтение из `orders`, экран в профиле или отдельный)  
3. Sentry  
4. Release APK (keystore, подпись, проверка установки на 2–3 телефонах)

**Цель: полноценный продукт через ~месяц**

1. Kaspi Pay  
2. Модификаторы (синхронизация с iiko)  
3. Сохранение корзины  
4. Зоны доставки  

---

## ✅ Phase 0 — Foundation (сделано)

- [x] Flutter MVP: меню, корзина, оформление заказа, бронирование, OTP-авторизация
- [x] Supabase: проект создан, схема задеплоена, 8 категорий в базе
- [x] WhatsApp-интеграция: заказы и брони → `+7 707 400 77 28`
- [x] iiko Cloud API интеграция: синхронизация меню + стоп-листы
- [x] GitHub Actions: `iiko_sync.yml` (раз в час) + `db_migrate.yml` (на push)
- [x] MCP-стек: dart-flutter + marionette + supabase + agent-browser
- [x] Claude Skills: flutter-architecture, riverpod-patterns, ui-screen-generator, api-integration, debug-ui, ui-test-loop
- [x] Design system документ
- [x] `.env` заполнен, `.env.example` создан, секреты в `.gitignore`
- [x] Документация: architecture, features, data-models, design-system, supabase-setup, iiko-sync
- [x] `menu_sync.py`: сохранение ручных `image_url` при пустом iiko
- [x] UI MVP: `FloatingCartBar`, stepper в `MenuItemCard`, правки категорий/статуса/брони
- [x] Premium Uzbek v1: `accentBlue`/`accentTerracotta`, `DishImagePlaceholder`, `IkatPatternBackground`, арки на категориях и промо
- [x] Splash Screen + тёмный native launch
- [x] Условия доставки (Павлодар, 700 / 10 000 тг, 45–75 мин) + расчёт в checkout
- [x] Guard `/item/:id` без `extra` → редирект на `/`
- [x] Поиск: debounce 300 ms (`SearchNotifier` + `searchProvider.autoDispose`)
- [x] Бронь: время в WhatsApp/БД всегда `HH:mm` (`_formatTime`)
- [x] Вкладка «Профиль» + `ProfileScreen` (`/profile`)
- [x] Patrol smoke test (splash, 3 вкладки, форма брони)
- [x] `AppConfig`: часы ресторана + `minDeliveryOrderAmount` (3 000 тг)
- [x] `delivery_rules`: `isShopOpen`, `isClosingSoon`, `shopClosedMessage`, `minOrderError`
- [x] `ShopStatusBadge` и `CheckoutScreen` на общих правилах (баннеры, блок кнопки)
- [x] Мультиязычность UI: ru + kk (`AppLocalizations`, переключатель в профиле)
- [x] Пуши по статусу заказа: FCM + `push_tokens` + Edge Function `send-order-push`

---

## 🔥 Phase 1 — Launch Prep (первые реальные клиенты)

> Цель: дать APK людям без «сырого» ощущения

### Критично

- [x] **История заказов** — `OrdersScreen` (`/orders`)
- [ ] **App icon** — launcher icons Android/iOS (бренд, не дефолтный Flutter)
- [ ] **Release APK** — keystore, `flutter build apk --release`, проверка установки на нескольких Android
- [ ] **Sentry** — crash reporting в release-сборке

### Контент и инфраструктура

- [ ] Запустить `python sync.py all` — залить меню из iiko в Supabase
- [ ] Загрузить фотографии блюд → Supabase Storage (`menu` bucket) + обновить `image_url` (sync не затирает ручные URL — см. [iiko-sync.md](iiko-sync.md#фотографии-блюд-image_url))
- [ ] Настроить Phone Auth — Twilio (SMS-провайдер в Supabase Dashboard)
- [ ] Тест на реальном устройстве Android / iOS
- [ ] Исправить баги после ручного тестирования
- [ ] Добавить GitHub Secrets для CI — см. [iiko-sync.md](iiko-sync.md#secrets-обязательно) и [supabase-setup.md](supabase-setup.md#github-actions-cicd)

---

## Phase 1.5 — Premium Uzbek (доработки)

> Базовая айдентика внедрена. Спека → [design-system.md](design-system.md#premium-uzbek--направление-айдентики)

- [ ] SVG-плейсхолдер казана в `assets/` (вместо Material-иконки)
- [ ] (Опционально) Display-шрифт с восточной вязью для «ПЛОВ НОМЕР 1»
- [x] `IkatPatternBackground` на `SplashScreen`
- [ ] (Опционально) Расширить икат на hero-блоки каталога

---

## 🚀 Phase 2 — Soft Launch (продукт через ~месяц)

> Цель: не терять деньги на допродаже и удобстве

- [ ] Модификаторы / допродажа (iiko: острый, без лука, порция) + cross-sell
- [ ] Сохранение корзины между сессиями (`shared_preferences`)
- [ ] Зоны доставки (валидация адреса / района)
- [ ] Раздать APK сотрудникам ресторана для теста
- [ ] Наполнить акции в `promotions` (UI `PromoBanner` на главной уже есть)
- [ ] Расширить «О ресторане» (сейчас bottom sheet на главной: адрес, часы, телефоны)
- [ ] Graceful offline — кеш меню локально
- [ ] Deep links на блюдо (`/item/:id` + загрузка по id из Supabase)

---

## 📈 Phase 3 — Growth

> Цель: повторные визиты, лояльность

- [ ] Повторный заказ из истории
- [ ] Маркетинговые пуши (акции) + переключатель в профиле
- [ ] Программа лояльности — баллы за заказы
- [ ] "Популярные у вас" — персонализация на главной
- [ ] Отзывы на блюда (`reviews` таблица)
- [ ] Веб-кабинет администратора (управление меню и заказами)

---

## 💳 Phase 4 — Monetization

> Цель: онлайн-оплата, рост среднего чека

- [ ] Kaspi Pay / Kaspi QR (приоритет для KZ)
- [ ] Upsell в корзине ("добавить напиток?")
- [ ] Промокоды
- [ ] Предзаказ к определённому времени

---

## 🌍 Phase 5 — Scale

> Цель: несколько точек, публикация в сторах

- [ ] Мультиязычность меню в БД (`name_kk` + sync iiko)
- [ ] Мультиресторан (несколько точек в одном приложении)
- [ ] Google Play публикация
- [ ] App Store публикация
- [ ] Аналитика: выручка, популярные блюда, конверсия корзины
