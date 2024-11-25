import '../models/product_model.dart';

abstract class IProductService {
  Future<List<Product>> getRecommendedProducts(String userId);
  Future<List<Product>> searchProducts(String query, {Map<String, dynamic>? filters});
  Future<void> reportProduct(String productId, String reason);
}