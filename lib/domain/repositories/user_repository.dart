import '../models/user_model.dart';
import '../models/review_model.dart';

abstract class IUserRepository {
  Future<UserModel?> getUserById(String id);
  Future<List<UserModel>> getAllUsers();
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> addReview(String userId, ReviewModel review);
  Future<List<ReviewModel>> getUserReviews(String userId);
  Future<void> toggleFavorite(String userId, String productId);
}
