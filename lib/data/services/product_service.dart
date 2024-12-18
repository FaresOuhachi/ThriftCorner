import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/product_service.dart';

class ProductService implements IProductService {
  final FirebaseFirestore _firestore;
  final IProductRepository _productRepository;

  ProductService(this._firestore, this._productRepository);

  @override
  Future<List<Product>> getRecommendedProducts(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception('User not found');

      final userData = userDoc.data()!;
      final List<String> viewedCategories = List<String>.from(userData['viewedCategories'] ?? []);
      final List<String> previousPurchases = List<String>.from(userData['previousPurchases'] ?? []);

      final QuerySnapshot recommendedProducts = await _firestore
          .collection('products')
          .where('isSold', isEqualTo: false)
          .where('category', whereIn: viewedCategories.take(10).toList())
          .limit(20)
          .get();

      return recommendedProducts.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((product) => !previousPurchases.contains(product.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recommended products: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query, {Map<String, dynamic>? filters}) async {
    try {
      Query productsQuery = _firestore.collection('products').where('isSold', isEqualTo: false);

      if (query.isNotEmpty) {
        productsQuery = productsQuery.where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: '$query\uf8ff');
      }

      if (filters != null) {
        if (filters['minPrice'] != null) {
          productsQuery = productsQuery.where('price', isGreaterThanOrEqualTo: filters['minPrice']);
        }
        if (filters['maxPrice'] != null) {
          productsQuery = productsQuery.where('price', isLessThanOrEqualTo: filters['maxPrice']);
        }
        if (filters['condition'] != null) {
          productsQuery = productsQuery.where('condition', isEqualTo: filters['condition']);
        }
      }

      final QuerySnapshot searchResults = await productsQuery.get();
      return searchResults.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<void> reportProduct(String productId, String reason) async {
    try {
      await _firestore.collection('reports').add({
        'productId': productId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending'
      });

      final productRef = _firestore.collection('products').doc(productId);
      await _firestore.runTransaction((transaction) async {
        final productDoc = await transaction.get(productRef);
        if (productDoc.exists) {
          final currentReports = productDoc.data()?['reportCount'] ?? 0;
          transaction.update(productRef, {'reportCount': currentReports + 1});

          if (currentReports + 1 >= 5) {
            transaction.update(productRef, {'flaggedForReview': true});
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to report product: $e');
    }
  }

  Future<void> trackProductView(String userId, String productId) async {
    try {
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) throw Exception('Product not found');

      final category = productDoc.data()?['category'] ?? '';

      await _firestore.collection('users').doc(userId).update({
        'viewedProducts': FieldValue.arrayUnion([productId]),
        'viewedCategories': FieldValue.arrayUnion([category]),
        'lastViewedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to track product view: $e');
    }
  }

  Future<List<Product>> getSimilarProducts(String productId) async {
    try {
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) throw Exception('Product not found');

      final productData = productDoc.data()!;
      final String category = productData['category'];
      final int price = productData['price'];

      final QuerySnapshot similarProducts = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .where('isSold', isEqualTo: false)
          .where('price', isGreaterThanOrEqualTo: price * 0.8)
          .where('price', isLessThanOrEqualTo: price * 1.2)
          .where(FieldPath.documentId, isNotEqualTo: productId)
          .limit(10)
          .get();

      return similarProducts.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get similar products: $e');
    }
  }
}
