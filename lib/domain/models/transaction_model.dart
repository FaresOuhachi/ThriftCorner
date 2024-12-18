import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionStatus { success, sent, cancelled }

class TransactionModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final double amountPaid;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.amountPaid,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      buyerId: map['buyerId'],
      sellerId: map['sellerId'],
      productId: map['productId'],
      amountPaid: map['amountPaid'],
      status: TransactionStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'],
        orElse: () => TransactionStatus.success,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'amountPaid': amountPaid,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
