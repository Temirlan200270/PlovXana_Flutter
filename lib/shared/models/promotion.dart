import 'package:equatable/equatable.dart';

class Promotion extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final bool active;

  const Promotion({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.active = true,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        active: (json['active'] as bool?) ?? true,
      );

  @override
  List<Object?> get props => [id, title];
}
