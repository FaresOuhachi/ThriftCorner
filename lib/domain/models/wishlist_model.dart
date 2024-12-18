import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Wishlist({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.createdAt,
    this.updatedAt,
  });

  factory Wishlist.fromMap(Map<String, dynamic> map) {
    return Wishlist(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      productIds: List<String>.from(map['productIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productIds': productIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
