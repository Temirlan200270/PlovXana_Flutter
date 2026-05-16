---
name: api-integration
description: Use when connecting a new Supabase table to the Flutter app, building data models, or debugging RLS/auth issues. Defines the model → provider → screen pipeline.
---

# API Integration — Supabase ↔ Flutter

## Pipeline

```
Supabase table
    ↓ (SQL schema)
Dart model (lib/shared/models/)
    ↓ (fromJson)
FutureProvider / StreamProvider (features/<f>/data/)
    ↓ (ref.watch)
Screen (features/<f>/presentation/)
```

## Шаги при добавлении новой таблицы

### 1. Создай таблицу + RLS в Supabase

Через Supabase MCP или SQL Editor:

```sql
create table if not exists favorites (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  item_id    uuid not null references menu_items(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, item_id)
);

alter table favorites enable row level security;

create policy "favorites_select_own" on favorites for select
  using (auth.uid() = user_id);
create policy "favorites_insert_own" on favorites for insert
  with check (auth.uid() = user_id);
create policy "favorites_delete_own" on favorites for delete
  using (auth.uid() = user_id);
```

**Правило:** все user-specific таблицы — `auth.uid() = user_id`. Публичные read — `using (true)`.

### 2. Создай Dart-модель

`lib/shared/models/favorite.dart`:

```dart
import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final String id;
  final String userId;
  final String itemId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        itemId: json['item_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toInsert(String userId) => {
        'user_id': userId,
        'item_id': itemId,
      };

  @override
  List<Object?> get props => [id, userId, itemId];
}
```

**Соглашения:**
- `extends Equatable` обязательно — без этого Riverpod не отличит одинаковые объекты
- `fromJson` — фабричный конструктор, snake_case ключи → camelCase поля
- `toInsert` — только поля для INSERT, без `id`/`created_at` (генерируются БД)
- `props` — только идентифицирующие поля (обычно `id`)

### 3. Создай провайдер

`lib/features/favorites/data/favorites_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/favorite.dart';
import '../../menu/data/menu_providers.dart';  // supabaseProvider

final favoritesProvider = FutureProvider<List<Favorite>>((ref) async {
  final client = ref.read(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final data = await client
      .from('favorites')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  return (data as List).map((e) => Favorite.fromJson(e)).toList();
});

// Mutation helpers — НЕ провайдеры, а функции
Future<void> addFavorite(WidgetRef ref, String itemId) async {
  final client = ref.read(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) throw StateError('Not authenticated');
  await client.from('favorites').insert({
    'user_id': user.id,
    'item_id': itemId,
  });
  ref.invalidate(favoritesProvider);  // перезагрузить список
}

Future<void> removeFavorite(WidgetRef ref, String favoriteId) async {
  final client = ref.read(supabaseProvider);
  await client.from('favorites').delete().eq('id', favoriteId);
  ref.invalidate(favoritesProvider);
}
```

### 4. Используй на экране

См. `ui-screen-generator` для template со всеми состояниями (loading/error/empty/data).

## Error handling

### Supabase возвращает `PostgrestException`

```dart
try {
  await client.from('orders').insert({...});
} on PostgrestException catch (e) {
  // e.code, e.message, e.details
  if (e.code == '42501') {
    // RLS violation — пользователь не авторизован или не имеет прав
  }
  rethrow;
}
```

### Сетевые ошибки

```dart
try {
  await client.from('menu_items').select();
} on SocketException {
  // Нет интернета
} on TimeoutException {
  // Сервер не отвечает
}
```

**Правило:** в `FutureProvider` не оборачивай в try/catch — ошибка автоматически попадёт в `AsyncValue.error` и UI покажет error-ветку.

## Realtime (опционально)

Для live-обновлений (например, статус заказа):

```dart
final orderStatusProvider = StreamProvider.family<String, String>((ref, orderId) {
  final client = ref.read(supabaseProvider);
  return client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', orderId)
      .map((rows) => rows.first['status'] as String);
});
```

Требует включения Realtime для таблицы в Supabase Dashboard → Database → Replication.

## RLS Debug checklist

Если запрос возвращает `[]` или `PostgrestException`:

1. **Проверь auth.uid()** — `Supabase.instance.client.auth.currentUser?.id`
2. **Проверь политики** — Dashboard → Authentication → Policies
3. **Запусти с service_role** в SQL Editor чтобы убедиться, что данные ЕСТЬ в таблице
4. **Проверь named columns** — RLS не покажет ошибку, просто отфильтрует ряды
5. **insert policy с `with check`** — для проверки записи, не `using`

## Anti-patterns

- ❌ `Supabase.instance.client.from(...)` прямо в widget — только через провайдер
- ❌ Хранение токенов / ключей в коде вне `lib/core/supabase/supabase_config.dart`
- ❌ Игнорирование `currentUser == null` — обязательно проверять перед запросами с RLS
- ❌ Возврат `Map<String, dynamic>` из провайдера — всегда типизированная модель
- ❌ `await ref.read(provider.future)` для триггера refetch — используй `ref.invalidate(provider)`
- ❌ Service role key в клиенте — ТОЛЬКО anon key, RLS обеспечивает безопасность
