import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thriftcorner/domain/repositories/user_repository.dart';
import '../../domain/models/review_model.dart';
import '../../domain/models/user_model.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      return doc.exists ? UserModel.fromMap(doc.data()!) : null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> addReview(String userId, ReviewModel review) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        await transaction.set(
            userRef.collection('reviews').doc(review.id), review.toMap());

        final userDoc = await transaction.get(userRef);
        final user = UserModel.fromMap(userDoc.data()!);

        final newReviewCount = user.reviewCount + 1;
        final newRating =
            ((user.rating * user.reviewCount) + review.rating) / newReviewCount;

        transaction.update(userRef, {
          'rating': newRating,
          'reviewCount': newReviewCount,
        });
      });
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      // Fetch reviews from the user's subcollection
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reviews')
          .get();

      // Check if there are any reviews, return an empty list if not
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Map the documents to ReviewModel and return as a list
      return querySnapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      // More specific error handling or logging can be added
      throw Exception('Failed to get user reviews for userId: $userId. Error: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String userId, String productId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final user = UserModel.fromMap(userDoc.data()!);

        List<String> updatedFavorites = List.from(user.favorites);
        if (updatedFavorites.contains(productId)) {
          updatedFavorites.remove(productId);
        } else {
          updatedFavorites.add(productId);
        }

        transaction.update(userRef, {
          'favorites': updatedFavorites,
        });
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }
}
