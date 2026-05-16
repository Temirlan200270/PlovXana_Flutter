import 'package:equatable/equatable.dart';

class Modifier extends Equatable {
  final String id;
  final String name;
  final int price;

  const Modifier({required this.id, required this.name, required this.price});

  factory Modifier.fromJson(Map<String, dynamic> json) => Modifier(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  @override
  List<Object?> get props => [id, name, price];
}

class ModifierGroup extends Equatable {
  final String id;
  final String name;
  final bool required;
  final int minAmount;
  final int maxAmount;
  final List<Modifier> modifiers;

  const ModifierGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.minAmount,
    required this.maxAmount,
    required this.modifiers,
  });

  factory ModifierGroup.fromJson(Map<String, dynamic> json) => ModifierGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        required: (json['required'] as bool?) ?? false,
        minAmount: (json['min_amount'] as num?)?.toInt() ?? 0,
        maxAmount: (json['max_amount'] as num?)?.toInt() ?? 1,
        modifiers: (json['modifiers'] as List? ?? [])
            .map((e) => Modifier.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, name, required, minAmount, maxAmount];
}
