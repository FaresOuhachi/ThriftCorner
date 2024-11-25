import '../models/product_model.dart';

abstract class IProductRepository {
  Future<Product?> getProductById(String id);
  Future<List<Product>> getProductsBySeller(String sellerId);
  Future<List<Product>> searchProducts(String query);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> markAsSold(String id);
}