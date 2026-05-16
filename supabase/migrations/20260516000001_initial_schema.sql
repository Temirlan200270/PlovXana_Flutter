create extension if not exists "uuid-ossp";

create table if not exists categories (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  image_url   text,
  iiko_id     uuid unique,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists menu_items (
  id           uuid primary key default uuid_generate_v4(),
  category_id  uuid not null references categories(id) on delete cascade,
  name         text not null,
  description  text,
  price        integer not null,
  image_url    text,
  weight_g     integer,
  iiko_id      uuid unique,
  is_halal     boolean not null default true,
  is_spicy     boolean not null default false,
  is_available boolean not null default true,
  is_popular   boolean not null default false,
  sort_order   integer not null default 0,
  created_at   timestamptz not null default now()
);

create table if not exists promotions (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  description text,
  image_url   text,
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

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

-- RLS
alter table categories  enable row level security;
alter table menu_items  enable row level security;
alter table promotions  enable row level security;
alter table orders      enable row level security;
alter table reservations enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where tablename='categories'  and policyname='categories_read_all')  then
    create policy "categories_read_all"  on categories  for select using (true); end if;
  if not exists (select 1 from pg_policies where tablename='menu_items'  and policyname='menu_items_read_all')  then
    create policy "menu_items_read_all"  on menu_items  for select using (true); end if;
  if not exists (select 1 from pg_policies where tablename='promotions'  and policyname='promotions_read_all')  then
    create policy "promotions_read_all"  on promotions  for select using (true); end if;
  if not exists (select 1 from pg_policies where tablename='orders' and policyname='orders_insert_own') then
    create policy "orders_insert_own" on orders for insert with check (auth.uid() = user_id); end if;
  if not exists (select 1 from pg_policies where tablename='orders' and policyname='orders_select_own') then
    create policy "orders_select_own" on orders for select using (auth.uid() = user_id); end if;
  if not exists (select 1 from pg_policies where tablename='reservations' and policyname='reservations_insert_own') then
    create policy "reservations_insert_own" on reservations for insert with check (true); end if;
  if not exists (select 1 from pg_policies where tablename='reservations' and policyname='reservations_select_own') then
    create policy "reservations_select_own" on reservations for select using (auth.uid() = user_id or user_id is null); end if;
end $$;

-- Seed categories (idempotent)
insert into categories (name, sort_order) values
  ('Плов',    1), ('Шашлык',  2), ('Манты',   3), ('Супы',    4),
  ('Салаты',  5), ('Лагман',  6), ('Напитки', 7), ('Десерты', 8)
on conflict do nothing;
