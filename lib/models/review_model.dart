import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String barberId;
  final String customerId;
  final String customerName;
  final double rating; // 1 to 5
  final String comment;
  final Timestamp timestamp;

  ReviewModel({
    required this.id,
    required this.barberId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      barberId: map['barberId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barberId': barberId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}