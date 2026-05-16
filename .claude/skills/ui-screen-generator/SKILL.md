---
name: ui-screen-generator
description: Use when scaffolding a new screen in the plovxana app. Defines standard layouts (list/detail/form/modal), required states (loading/error/empty), and integration with the design system.
---

# UI Screen Generator — plovxana

## Шаги создания экрана

1. **Определи тип** (список, деталь, форма, модал) — см. templates ниже
2. **Создай файл** в `features/<feature>/presentation/screens/<name>_screen.dart`
3. **Используй ConsumerWidget / ConsumerStatefulWidget** (см. `riverpod-patterns`)
4. **Импортируй ТОЛЬКО `AppColors`**, не пиши `Color(0xFF...)` inline
5. **Добавь маршрут** в [lib/core/router/app_router.dart](../../../lib/core/router/app_router.dart)
6. **Обработай все три состояния** для async-данных: loading / error / empty / data
7. **Запусти flutter analyze** перед коммитом

## Spacing scale

Используй ТОЛЬКО эти значения для padding/margin/SizedBox:

```
4   — между иконкой и текстом внутри chip
8   — между связанными элементами (label + input)
12  — между элементами в карточке
16  — стандартный padding контейнера
20  — padding экрана по краям
24  — между секциями экрана
32  — большие отступы (между блоками формы)
48  — hero-секции, top-padding для эмоциональных моментов
```

## Template — Список с async-данными

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) return _empty();
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ItemTile(item: items[i]),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _error(e.toString(), () => ref.invalidate(favoritesProvider)),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text('Пусто', style: TextStyle(color: AppColors.greyLight, fontSize: 16)),
          ],
        ),
      );

  Widget _error(String msg, VoidCallback onRetry) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(msg, style: const TextStyle(color: AppColors.greyLight)),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      );
}
```

## Template — Форма

```dart
class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key});

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      _showError('Заполните обязательные поля');
      return;
    }
    setState(() => _loading = true);
    try {
      // ... запись через провайдер
      if (mounted) context.go('/order-sent');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заголовок')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // секции через _sectionTitle + поля
            // итоговый блок суммы (если есть)
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('Отправить'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
```

## Template — Detail page (с hero)

```dart
class ItemDetailScreen extends ConsumerWidget {
  final MenuItem item;
  const ItemDetailScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'item-${item.id}',
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(item.name, style: Theme.of(context).textTheme.displaySmall),
                // ...
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => ref.read(cartProvider.notifier).add(item),
            child: const Text('Добавить в корзину'),
          ),
        ),
      ),
    );
  }
}
```

## Обязательные состояния

Каждый экран с async-данными ДОЛЖЕН обрабатывать:

| State | UI |
|---|---|
| Loading | `CircularProgressIndicator(color: AppColors.primary)` по центру |
| Error | Иконка `error_outline` + текст + кнопка "Повторить" |
| Empty | Иконка по контексту + текст "Пусто" / "Ничего не найдено" |
| Data | Основной layout |

## Anti-patterns

- ❌ Только `data:` ветка в `.when()` — игнорирование loading/error → краш или вечный спиннер
- ❌ `setState` в `build`
- ❌ Inline-цвета: `color: Color(0xFFC9A84C)` → используй `AppColors.primary`
- ❌ Произвольный spacing: `padding: EdgeInsets.all(13)` → только 4/8/12/16/20/24/32
- ❌ `Text('Add to cart')` — английский. Только русский.
- ❌ Прямой вызов `Navigator.of(context).push(...)` — используй `context.go()` / `context.push()` через GoRouter
