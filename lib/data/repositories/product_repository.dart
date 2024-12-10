import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepository implements IProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      return doc.exists ? Product.fromMap(doc.data()!, doc.id) : null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('title', isGreaterThanOrEqualTo: query)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<void> markAsSold(String id) async {
    try {
      await _firestore.collection('products').doc(id).update({'isSold': true});
    } catch (e) {
      throw Exception('Failed to mark product as sold: $e');
    }
  }

  Future<List<Product>> getProductsByFilter({String? category, double? minPrice, double? maxPrice, String? condition, String? location, bool? isSold, int limit = 20,}) async {
    try {
      Query query = _firestore.collection('products');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }
      if (condition != null) {
        query = query.where('condition', isEqualTo: condition);
      }
      if (location != null) {
        query = query.where('location', isEqualTo: location);
      }
      if (isSold != null) query = query.where('isSold', isEqualTo: isSold);

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter products: $e');
    }
  }
}
