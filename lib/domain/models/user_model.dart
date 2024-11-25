import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_model.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String gender;
  final String? address;
  final String? country;
  final String? profileImage;
  final String? phoneNumber;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final List<String> favorites;
  final List<ReviewModel> reviews;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.gender,
    this.address,
    this.country,
    this.profileImage,
    this.phoneNumber,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.favorites = const [],
    this.reviews = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      gender: map['gender'],
      address: map['address'],
      country: map['country'],
      profileImage: map['profileImage'],
      phoneNumber: map['phoneNumber'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      favorites: List<String>.from(map['favorites'] ?? []),
      reviews: (map['reviews'] ?? []).map((review) => ReviewModel.fromMap(review)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'gender': gender,
      'address': address,
      'country': country,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'favorites': favorites,
      'reviews': reviews.map((review) => review.toMap()).toList(),
    };
  }
}
