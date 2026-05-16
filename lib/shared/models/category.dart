import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        imageUrl: json['image_url'] as String?,
        sortOrder: (json['sort_order'] as int?) ?? 0,
      );

  @override
  List<Object?> get props => [id, name, imageUrl, sortOrder];
}
