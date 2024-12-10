import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String sellerId;
  final List<String> images;
  final String size;
  final double price;
  final String color;
  final String condition;
  final String description;
  final bool isSold;
  final DateTime uploadedAt;

  Product({
    required this.id,
    required this.title,
    required this.sellerId,
    required this.images,
    required this.size,
    required this.price,
    required this.color,
    required this.condition,
    required this.description,
    required this.isSold,
    required this.uploadedAt,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      title: data['title'] ?? '',
      sellerId: data['sellerId'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      size: data['size'] ?? '',
      price: data['price'] ?? 0.0,
      color: data['color'] ?? '',
      condition: data['condition'] ?? '',
      description: data['description'] ?? '',
      isSold: data['isSold'] ?? false,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'sellerId': sellerId,
      'images': images,
      'size': size,
      'price': price,
      'color': color,
      'condition': condition,
      'description': description,
      'isSold': isSold,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
