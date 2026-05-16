import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/l10n/delivery_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/menu_item.dart';
import '../../../../shared/models/modifier_group.dart';
import '../../../../shared/widgets/dish_image_placeholder.dart';
import '../../../cart/data/cart_provider.dart';
import '../../data/menu_providers.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final MenuItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  final Map<String, Modifier?> _selectedModifiers = {};

  bool _isValid(List<ModifierGroup> groups) {
    for (final g in groups) {
      if (g.required && _selectedModifiers[g.id] == null) return false;
    }
    return true;
  }

  int _modifiersTotal(List<ModifierGroup> groups) {
    int total = 0;
    for (final g in groups) {
      final m = _selectedModifiers[g.id];
      if (m != null) total += m.price;
    }
    return total;
  }

  List<Modifier> _selectedList() =>
      _selectedModifiers.values.whereType<Modifier>().toList();

  void _addToCart(List<ModifierGroup> groups) {
    final mods = _selectedList();
    if (mods.isEmpty) {
      ref.read(cartProvider.notifier).add(widget.item);
    } else {
      ref.read(cartProvider.notifier).addWithModifiers(widget.item, mods);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);
    final cartItem = cart.where((e) => e.item.id == widget.item.id).firstOrNull;
    final quantity = cartItem?.quantity ?? 0;
    final groupsAsync = ref.watch(modifierGroupsProvider(widget.item.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.item.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          const DishImagePlaceholder(iconSize: 64),
                    )
                  : const DishImagePlaceholder(iconSize: 64),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.item.isHalal) _tag(l10n.halal, AppColors.halal),
                      if (widget.item.isSpicy) ...[
                        const SizedBox(width: 8),
                        _tag('${l10n.spicy} 🌶', AppColors.spicy),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.item.name,
                      style: Theme.of(context).textTheme.displaySmall),
                  if (widget.item.weightG != null) ...[
                    const SizedBox(height: 4),
                    Text(l10n.weightGrams(widget.item.weightG!),
                        style: const TextStyle(
                            color: AppColors.greyLight, fontSize: 14)),
                  ],
                  if (widget.item.description != null) ...[
                    const SizedBox(height: 16),
                    Text(widget.item.description!,
                        style: const TextStyle(
                            color: AppColors.greyLight,
                            fontSize: 14,
                            height: 1.6)),
                  ],
                  // Modifier groups
                  groupsAsync.when(
                    data: (groups) {
                      if (groups.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          ...groups.map((g) => _ModifierGroupSection(
                                group: g,
                                selected: _selectedModifiers[g.id],
                                onSelect: (m) => setState(
                                    () => _selectedModifiers[g.id] = m),
                              )),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: LinearProgressIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  groupsAsync.maybeWhen(
                    data: (groups) {
                      final modTotal = _modifiersTotal(groups);
                      final total = widget.item.price + modTotal;
                      return Text(
                        '${_fmt(total)} тг',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                    orElse: () => Text(
                      '${_fmt(widget.item.price)} тг',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: groupsAsync.maybeWhen(
            data: (groups) {
              final hasGroups = groups.isNotEmpty;
              final valid = !hasGroups || _isValid(groups);
              if (quantity == 0 || hasGroups) {
                return ElevatedButton(
                  onPressed: valid ? () => _addToCart(groups) : null,
                  child: Text(hasGroups && !valid
                      ? l10n.selectRequiredModifiers
                      : l10n.addToCart),
                );
              }
              return Row(
                children: [
                  _CounterBtn(
                    icon: Icons.remove,
                    onTap: () =>
                        ref.read(cartProvider.notifier).remove(widget.item.id),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$quantity шт · ${_fmt(widget.item.price * quantity)} тг',
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  _CounterBtn(
                    icon: Icons.add,
                    onTap: () =>
                        ref.read(cartProvider.notifier).add(widget.item),
                  ),
                ],
              );
            },
            orElse: () => quantity == 0
                ? ElevatedButton(
                    onPressed: () => _addToCart([]),
                    child: Text(l10n.addToCart),
                  )
                : Row(
                    children: [
                      _CounterBtn(
                        icon: Icons.remove,
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .remove(widget.item.id),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$quantity шт · ${_fmt(widget.item.price * quantity)} тг',
                            style: const TextStyle(
                              color: AppColors.cream,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      _CounterBtn(
                        icon: Icons.add,
                        onTap: () =>
                            ref.read(cartProvider.notifier).add(widget.item),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  String _fmt(int price) => price
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
}

class _ModifierGroupSection extends StatelessWidget {
  final ModifierGroup group;
  final Modifier? selected;
  final ValueChanged<Modifier?> onSelect;

  const _ModifierGroupSection({
    required this.group,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(group.name,
                style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            if (group.required) ...[
              const SizedBox(width: 6),
              const Text('*',
                  style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.modifiers.map((m) {
            final isSelected = selected?.id == m.id;
            return GestureDetector(
              onTap: () => onSelect(isSelected ? null : m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(m.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.cream,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
                    if (m.price > 0) ...[
                      const SizedBox(height: 2),
                      Text('+${m.price} тг',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.greyLight,
                            fontSize: 11,
                          )),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.cream),
      ),
    );
  }
}
