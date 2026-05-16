-- ============================================================
-- ПЛОВ НОМЕР 1 — Supabase SQL миграции
-- Выполни в Supabase Dashboard → SQL Editor
-- ============================================================

-- EXTENSIONS
create extension if not exists "uuid-ossp";

-- ============================================================
-- CATEGORIES
-- ============================================================
create table if not exists categories (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  image_url   text,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- MENU ITEMS
-- ============================================================
create table if not exists menu_items (
  id           uuid primary key default uuid_generate_v4(),
  category_id  uuid not null references categories(id) on delete cascade,
  name         text not null,
  description  text,
  price        integer not null,           -- в тенге, целое
  image_url    text,
  weight_g     integer,
  is_halal     boolean not null default true,
  is_spicy     boolean not null default false,
  is_available boolean not null default true,
  is_popular   boolean not null default false,
  sort_order   integer not null default 0,
  created_at   timestamptz not null default now()
);

-- ============================================================
-- PROMOTIONS
-- ============================================================
create table if not exists promotions (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  description text,
  image_url   text,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- ORDERS
-- ============================================================
create table if not exists orders (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid references auth.users(id),
  status        text not null default 'pending',
  items_json    jsonb not null default '[]',
  total         integer not null,
  delivery_type text not null default 'delivery',
  address       text,
  phone         text,
  comment       text,
  created_at    timestamptz not null default now()
);

-- ============================================================
-- RESERVATIONS
-- ============================================================
create table if not exists reservations (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid references auth.users(id),
  date         date not null,
  time         time not null,
  guests_count integer not null,
  comment      text,
  phone        text,
  name         text,
  status       text not null default 'pending',
  created_at   timestamptz not null default now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- categories: публичное чтение
alter table categories enable row level security;
create policy "categories_read_all" on categories for select using (true);

-- menu_items: публичное чтение
alter table menu_items enable row level security;
create policy "menu_items_read_all" on menu_items for select using (true);

-- promotions: публичное чтение
alter table promotions enable row level security;
create policy "promotions_read_all" on promotions for select using (true);

-- orders: только свои
alter table orders enable row level security;
create policy "orders_insert_own" on orders for insert
  with check (auth.uid() = user_id);
create policy "orders_select_own" on orders for select
  using (auth.uid() = user_id);

-- reservations: только свои
alter table reservations enable row level security;
create policy "reservations_insert_own" on reservations for insert
  with check (true);  -- разрешаем даже без auth (гость может забронировать)
create policy "reservations_select_own" on reservations for select
  using (auth.uid() = user_id or user_id is null);

-- ============================================================
-- SEED DATA — Категории
-- ============================================================
insert into categories (name, sort_order) values
  ('Плов',      1),
  ('Шашлык',    2),
  ('Манты',     3),
  ('Супы',      4),
  ('Салаты',    5),
  ('Лагман',    6),
  ('Напитки',   7),
  ('Десерты',   8);

-- ============================================================
-- SEED DATA — Примеры блюд (замени ценами ресторана)
-- ============================================================
-- Сначала получи id категорий:
-- select id, name from categories;
-- Затем вставь блюда, подставив реальные category_id

-- Пример (подставь свой category_id после создания категорий):
-- insert into menu_items (category_id, name, price, weight_g, is_halal, is_popular)
-- values
--   ('UUID_PLOV', 'Плов классический', 2500, 350, true, true),
--   ('UUID_PLOV', 'Плов с изюмом', 2800, 350, true, false),
--   ('UUID_SHASHLIK', 'Шашлык из баранины', 4500, 300, true, true);
