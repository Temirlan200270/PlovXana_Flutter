# Roadmap — ПЛОВ НОМЕР 1

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

---

## 🔥 Phase 1 — Launch Prep

> Цель: запустить приложение в ресторане

- [ ] Запустить `python sync.py all` — залить меню из iiko в Supabase
- [ ] Загрузить фотографии блюд → Supabase Storage (`menu` bucket) + обновить `image_url` (sync не затирает ручные URL — см. [iiko-sync.md](iiko-sync.md#фотографии-блюд-image_url))
- [ ] Настроить Phone Auth — Twilio (SMS-провайдер в Supabase Dashboard)
- [ ] Тест на реальном устройстве Android
- [ ] Тест на реальном устройстве iOS
- [ ] `flutter build apk --release` → установить APK, проверить вживую
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

## 🚀 Phase 2 — Soft Launch

> Цель: первые реальные заказы

- [ ] Модификаторы / допродажа (лепешка, салат к плову) — cross-sell
- [ ] Вкладка «Профиль»: история заказов, данные, выход
- [ ] Раздать APK сотрудникам ресторана для теста
- [ ] Добавить акции (`promotions`) — баннеры на главной
- [ ] Экран "О ресторане" — адрес, часы работы, телефон
- [ ] Graceful fallback при отсутствии интернета
- [ ] Crash reporting — Sentry

---

## 📈 Phase 3 — Growth

> Цель: повторные визиты, лояльность

- [ ] История заказов пользователя (`orders` → экран)
- [ ] Push-уведомления (статус заказа, акции) — FCM
- [ ] Программа лояльности — баллы за заказы
- [ ] "Популярные у вас" — персонализация на главной
- [ ] Отзывы на блюда (`reviews` таблица)
- [ ] Веб-кабинет администратора (управление меню и заказами)

---

## 💳 Phase 4 — Monetization

> Цель: онлайн-оплата, рост среднего чека

- [ ] Kaspi Pay / Kaspi QR интеграция
- [ ] Upsell в корзине ("добавить напиток?")
- [ ] Промокоды
- [ ] Предзаказ к определённому времени

---

## 🌍 Phase 5 — Scale

> Цель: несколько точек, публикация в сторах

- [ ] Мультиязычность: казахский + русский
- [ ] Мультиресторан (несколько точек в одном приложении)
- [ ] Google Play публикация
- [ ] App Store публикация
- [ ] Аналитика: выручка, популярные блюда, конверсия корзины
