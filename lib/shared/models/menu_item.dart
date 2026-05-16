import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final int price;
  final String? imageUrl;
  final int? weightG;
  final bool isHalal;
  final bool isSpicy;
  final bool isAvailable;
  final int sortOrder;

  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.weightG,
    this.isHalal = false,
    this.isSpicy = false,
    this.isAvailable = true,
    this.sortOrder = 0,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toInt(),
        imageUrl: json['image_url'] as String?,
        weightG: json['weight_g'] as int?,
        isHalal: (json['is_halal'] as bool?) ?? false,
        isSpicy: (json['is_spicy'] as bool?) ?? false,
        isAvailable: (json['is_available'] as bool?) ?? true,
        sortOrder: (json['sort_order'] as int?) ?? 0,
      );

  @override
  List<Object?> get props => [id, categoryId, name, price];
}
