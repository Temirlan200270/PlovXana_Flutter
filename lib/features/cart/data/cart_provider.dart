import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/models/menu_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(MenuItem item) {
    final idx = state.indexWhere((e) => e.item.id == item.id);
    if (idx >= 0) {
      final updated = [...state];
      updated[idx] = state[idx].copyWith(quantity: state[idx].quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(item: item)];
    }
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
  }

  void delete(String itemId) {
    state = state.where((e) => e.item.id != itemId).toList();
  }

  void clear() => state = [];

  int get totalItems => state.fold(0, (sum, e) => sum + e.quantity);

  int get totalPrice => state.fold(0, (sum, e) => sum + e.total);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (_) => CartNotifier(),
);

final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, e) => sum + e.total);
});

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, e) => sum + e.quantity);
});
