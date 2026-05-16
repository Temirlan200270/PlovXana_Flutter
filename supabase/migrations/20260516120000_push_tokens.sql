create table if not exists push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  fcm_token text not null,
  platform text not null check (platform in ('android', 'ios')),
  locale text not null default 'ru' check (locale in ('ru', 'kk')),
  updated_at timestamptz not null default now(),
  unique (user_id, fcm_token)
);

create index if not exists push_tokens_user_id_idx on push_tokens (user_id);

alter table push_tokens enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where tablename = 'push_tokens' and policyname = 'push_tokens_select_own'
  ) then
    create policy push_tokens_select_own on push_tokens
      for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where tablename = 'push_tokens' and policyname = 'push_tokens_insert_own'
  ) then
    create policy push_tokens_insert_own on push_tokens
      for insert with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where tablename = 'push_tokens' and policyname = 'push_tokens_update_own'
  ) then
    create policy push_tokens_update_own on push_tokens
      for update using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where tablename = 'push_tokens' and policyname = 'push_tokens_delete_own'
  ) then
    create policy push_tokens_delete_own on push_tokens
      for delete using (auth.uid() = user_id);
  end if;
end $$;
