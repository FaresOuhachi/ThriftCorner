
import '../models/wishlist_model.dart';

abstract class IWishlistRepository {
  Future<Wishlist?> getWishlistByUser(String userId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);
  Future<bool> isProductInWishlist(String userId, String productId);
}
