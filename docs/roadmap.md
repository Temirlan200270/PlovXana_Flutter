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
- [x] Документация: architecture, features, data-models, design-system, supabase-setup

---

## 🔥 Phase 1 — Launch Prep

> Цель: запустить приложение в ресторане

- [ ] Запустить `python sync.py all` — залить меню из iiko в Supabase
- [ ] Загрузить фотографии блюд → Supabase Storage (`menu` bucket) + обновить `image_url`
- [ ] Настроить Phone Auth — Twilio (SMS-провайдер в Supabase Dashboard)
- [ ] Тест на реальном устройстве Android
- [ ] Тест на реальном устройстве iOS
- [ ] `flutter build apk --release` → установить APK, проверить вживую
- [ ] Исправить баги после ручного тестирования
- [ ] Добавить GitHub Secrets (`IIKO_API_LOGIN`, `SUPABASE_SERVICE_ROLE_KEY` и др.) для CI

---

## 🚀 Phase 2 — Soft Launch

> Цель: первые реальные заказы

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
