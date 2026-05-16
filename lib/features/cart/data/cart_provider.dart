import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/user_prefs.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/menu_item.dart';
import '../../../shared/models/modifier_group.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  final SharedPreferences _prefs;
  static const _key = 'cart_items';

  CartNotifier(this._prefs) : super(_load(_prefs));

  static List<CartItem> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _persist() {
    _prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void add(MenuItem item) {
    final idx = state.indexWhere((e) => e.item.id == item.id && e.modifiers.isEmpty);
    if (idx >= 0) {
      final updated = [...state];
      updated[idx] = state[idx].copyWith(quantity: state[idx].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(item: item)];
    }
    _persist();
  }

  void addWithModifiers(MenuItem item, List<Modifier> modifiers) {
    final modIds = modifiers.map((m) => m.id).toList()..sort();
    final idx = state.indexWhere((e) {
      if (e.item.id != item.id) return false;
      final existing = e.modifiers.map((m) => m.id).toList()..sort();
      return existing.join(',') == modIds.join(',');
    });
    if (idx >= 0) {
      final updated = [...state];
      updated[idx] = state[idx].copyWith(quantity: state[idx].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(item: item, modifiers: modifiers)];
    }
    _persist();
  }

  void remove(String itemId) {
    final idx = state.indexWhere((e) => e.item.id == itemId);
    if (idx < 0) return;
    if (state[idx].quantity > 1) {
      final updated = [...state];
      updated[idx] = state[idx].copyWith(quantity: state[idx].quantity - 1);
      state = updated;
    } else {
      state = state.where((e) => e.item.id != itemId).toList();
    }
    _persist();
  }

  void delete(String itemId) {
    state = state.where((e) => e.item.id != itemId).toList();
    _persist();
  }

  void clear() {
    state = [];
    _persist();
  }

  int get totalItems => state.fold(0, (sum, e) => sum + e.quantity);
  int get totalPrice => state.fold(0, (sum, e) => sum + e.total);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(ref.read(sharedPreferencesProvider)),
);

final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, e) => sum + e.total);
});

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, e) => sum + e.quantity);
});
