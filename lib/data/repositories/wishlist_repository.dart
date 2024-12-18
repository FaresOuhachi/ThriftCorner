import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/models/wishlist_model.dart';

class WishlistRepository implements IWishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepository(this._firestore);

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      final wishlistRef = _firestore.collection('wishlists').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);

        if (wishlistDoc.exists) {
          // If wishlist exists, update the list of product IDs
          final wishlistData = wishlistDoc.data();
          final wishlist = Wishlist.fromMap(wishlistData!);

          if (!wishlist.productIds.contains(productId)) {
            final updatedProducts = List<String>.from(wishlist.productIds)..add(productId);
            transaction.update(wishlistRef, {'productIds': updatedProducts});
          }
        } else {
          // If wishlist doesn't exist, create a new wishlist with the product ID
          final newWishlist = Wishlist(
            id: userId,  // Using userId as the wishlist ID
            userId: userId,
            productIds: [productId],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          transaction.set(wishlistRef, newWishlist.toMap());
        }
      });
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      final wishlistRef = _firestore.collection('wishlists').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);

        if (!wishlistDoc.exists) {
          throw Exception('Wishlist not found for user: $userId');
        }

        final wishlist = Wishlist.fromMap(wishlistDoc.data()!);

        if (wishlist.productIds.contains(productId)) {
          wishlist.productIds.remove(productId);
          transaction.update(wishlistRef, {'productIds': wishlist.productIds});
        } else {
          throw Exception('Product not found in wishlist');
        }
      });
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  @override
  Future<bool> isProductInWishlist(String userId, String productId) async {
    try {
      final doc = await _firestore.collection('wishlists').doc(userId).get();

      if (!doc.exists) return false;

      final wishlist = Wishlist.fromMap(doc.data()!);

      return wishlist.productIds.contains(productId);
    } catch (e) {
      throw Exception('Failed to check if product is in wishlist: $e');
    }
  }

  @override
  Future<Wishlist?> getWishlistByUser(String userId) async {
    try {
      final doc = await _firestore.collection('wishlists').doc(userId).get();

      if (!doc.exists || doc.data() == null) return null;

      return Wishlist.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get wishlist for user $userId: $e');
    }
  }
}
