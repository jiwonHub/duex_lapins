import 'package:duex_lapins/domain/models/product.dart';

abstract class CatalogRepository {
  Future<List<Product>> getProducts();
}
