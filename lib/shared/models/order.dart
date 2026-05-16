import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String status;
  final List<Map<String, dynamic>> itemsJson;
  final int total;
  final String deliveryType;
  final String? address;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.status,
    required this.itemsJson,
    required this.total,
    required this.deliveryType,
    this.address,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        status: json['status'] as String? ?? 'pending',
        itemsJson: (json['items_json'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        total: (json['total'] as num).toInt(),
        deliveryType: json['delivery_type'] as String? ?? 'delivery',
        address: json['address'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  List<Object?> get props => [id, status, total, createdAt];
}
