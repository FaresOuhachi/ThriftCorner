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
        final wishlistData = wishlistDoc.data();

        if (wishlistData != null) {
          final wishlist = Wishlist.fromMap(wishlistData);

          // Avoid mutation directly on the list, create a new list with the product added
          if (!wishlist.productIds.contains(productId)) {
            final updatedProducts = List<String>.from(wishlist.productIds)
              ..add(productId);
            transaction.update(wishlistRef, {'products': updatedProducts});
          }
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

      // Start a Firestore transaction to ensure atomic updates
      await _firestore.runTransaction((transaction) async {
        final wishlistDoc = await transaction.get(wishlistRef);

        // If the wishlist doesn't exist, throw an error
        if (!wishlistDoc.exists) {
          throw Exception('Wishlist not found for user: $userId');
        }

        // Convert the document to a Wishlist object
        final wishlist = Wishlist.fromMap(wishlistDoc.data()!);

        // Remove the product if it exists in the list
        if (wishlist.productIds.contains(productId)) {
          wishlist.productIds.remove(productId);
          // Update the wishlist in Firestore
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

      // If the wishlist document doesn't exist, return false
      if (!doc.exists) return false;

      // Convert the document to a Wishlist object
      final wishlist = Wishlist.fromMap(doc.data()!);

      // Check if the productId exists in the productIds list
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