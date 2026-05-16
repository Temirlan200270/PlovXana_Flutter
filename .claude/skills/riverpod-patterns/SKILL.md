---
name: riverpod-patterns
description: Use whenever working with state in the plovxana app. Defines which Riverpod provider type to choose, when to use ref.watch vs ref.read, and naming conventions.
---

# Riverpod Patterns — plovxana

## Provider selection cheat-sheet

| Что нужно | Provider type | Пример |
|---|---|---|
| Константное значение (Supabase client) | `Provider` | `supabaseProvider` |
| Однократная загрузка из API | `FutureProvider` | `categoriesProvider` |
| Загрузка с параметром | `FutureProvider.family` | `menuItemsByCategoryProvider(id)` |
| Мутируемое состояние | `StateNotifierProvider` | `cartProvider` |
| Простое мутируемое значение (bool, int) | `StateProvider` | `_deliveryTypeProvider` |
| Стрим из Supabase | `StreamProvider` | (новые заказы realtime) |
| Производное значение | `Provider` (вычисляет из ref.watch) | `cartTotalProvider` |

## ref.watch vs ref.read

```dart
// ✅ В build / Consumer — ВСЕГДА watch
@override
Widget build(BuildContext context, WidgetRef ref) {
  final cart = ref.watch(cartProvider);  // перерисует при изменении
  return Text('${cart.length}');
}

// ✅ В callback / onPressed — ВСЕГДА read
ElevatedButton(
  onPressed: () {
    ref.read(cartProvider.notifier).add(item);  // НЕ подписываемся
  },
)

// ❌ НИКОГДА не watch в callback — приведёт к утечке подписок
onPressed: () => ref.watch(cartProvider.notifier).add(item)  // BAD

// ❌ НИКОГДА не read в build — потеряешь реактивность
final cart = ref.read(cartProvider);  // BAD: не перерисуется
```

## ConsumerWidget vs ConsumerStatefulWidget

- **Нет локального state** (контроллеров, фокусов, анимаций) → `ConsumerWidget`
- **Есть TextEditingController / FocusNode / AnimationController** → `ConsumerStatefulWidget`
- **Нужен `initState` / `dispose`** → `ConsumerStatefulWidget`

## StateNotifier — шаблон

```dart
// 1. Класс нотифаера
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(MenuItem item) {
    // ✅ Immutable updates — новый список, не mutate
    final idx = state.indexWhere((e) => e.item.id == item.id);
    if (idx >= 0) {
      final updated = [...state];
      updated[idx] = state[idx].copyWith(quantity: state[idx].quantity + 1);
      state = updated;  // присваивание триггерит rebuild
    } else {
      state = [...state, CartItem(item: item)];
    }
  }
}

// 2. Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (_) => CartNotifier(),
);

// 3. Производные провайдеры — ВСЕГДА reactive через watch
final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);  // НЕ read
  return cart.fold(0, (sum, e) => sum + e.total);
});
```

**Почему `[...state]`?** State в `StateNotifier` сравнивается по identity. Mutate-операции (`state.add(...)`) не триггерят rebuild.

## FutureProvider — шаблон

```dart
// ✅ Standard
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('categories').select().order('sort_order');
  return (data as List).map((e) => Category.fromJson(e)).toList();
});

// ✅ С параметром — .family
final menuItemsByCategoryProvider =
    FutureProvider.family<List<MenuItem>, String>((ref, categoryId) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('menu_items')
      .select()
      .eq('category_id', categoryId)
      .eq('is_available', true)
      .order('sort_order');
  return (data as List).map((e) => MenuItem.fromJson(e)).toList();
});
```

## Использование AsyncValue в UI

```dart
final itemsAsync = ref.watch(menuItemsByCategoryProvider(categoryId));

return itemsAsync.when(
  data: (items) => ListView.builder(...),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(child: Text('Ошибка: $e')),
);
```

**Никогда не пиши:**
```dart
// ❌ Нарушает Riverpod-инвариант
final items = await ref.read(categoriesProvider.future);
```

## Когда invalidate / refresh

```dart
// После мутации (например, добавили блюдо в админке)
ref.invalidate(categoriesProvider);  // следующий watch перезапросит

// Pull-to-refresh
RefreshIndicator(
  onRefresh: () async => ref.invalidate(menuItemsByCategoryProvider(id)),
  child: ...,
)
```

## Naming

| Что | Pattern |
|---|---|
| Public provider | `<name>Provider` (например, `cartProvider`) |
| Private provider (внутри файла экрана) | `_<name>Provider` |
| Notifier class | `<Name>Notifier` (например, `CartNotifier`) |
| Параметризованный | `<entity>By<Param>Provider` (например, `menuItemsByCategoryProvider`) |

## Anti-patterns

- ❌ Хранение `BuildContext` в state
- ❌ Async-вызовы внутри `build`
- ❌ `ref.read` в build-методе
- ❌ Мутация state без присваивания (`state.add(x)` вместо `state = [...state, x]`)
- ❌ Передача `WidgetRef` в виджеты-внуки (используй `Consumer` внутри)
- ❌ Состояние формы (TextEditingController) внутри StateNotifier — используй `StatefulWidget` для UI-state, Riverpod для domain state
