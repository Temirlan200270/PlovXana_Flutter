import 'package:equatable/equatable.dart';
import 'menu_item.dart';
import 'modifier_group.dart';

class CartItem extends Equatable {
  final MenuItem item;
  final int quantity;
  final List<Modifier> modifiers;

  const CartItem({
    required this.item,
    this.quantity = 1,
    this.modifiers = const [],
  });

  int get modifiersPrice => modifiers.fold(0, (sum, m) => sum + m.price);
  int get total => (item.price + modifiersPrice) * quantity;

  CartItem copyWith({int? quantity, List<Modifier>? modifiers}) => CartItem(
        item: item,
        quantity: quantity ?? this.quantity,
        modifiers: modifiers ?? this.modifiers,
      );

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'quantity': quantity,
        'modifiers': modifiers.map((m) => m.toJson()).toList(),
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        item: MenuItem.fromJson(json['item'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
        modifiers: (json['modifiers'] as List? ?? [])
            .map((e) => Modifier.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [item, quantity, modifiers];
}
