import 'package:deux_lapins/domain/models/product.dart';

abstract class CatalogRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProduct(String productId);
}
