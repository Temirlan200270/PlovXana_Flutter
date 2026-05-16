import 'package:equatable/equatable.dart';

class Reservation extends Equatable {
  final String id;
  final String? userId;
  final String date;
  final String time;
  final int guestsCount;
  final String? comment;
  final String? phone;
  final String? name;
  final String status;

  const Reservation({
    required this.id,
    this.userId,
    required this.date,
    required this.time,
    required this.guestsCount,
    this.comment,
    this.phone,
    this.name,
    this.status = 'pending',
  });

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        date: json['date'] as String,
        time: json['time'] as String,
        guestsCount: json['guests_count'] as int,
        comment: json['comment'] as String?,
        phone: json['phone'] as String?,
        name: json['name'] as String?,
        status: (json['status'] as String?) ?? 'pending',
      );

  @override
  List<Object?> get props => [id, date, time, guestsCount];
}
