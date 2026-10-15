import 'package:deux_lapins/data/models/product_model.dart';
import 'package:deux_lapins/data/services/catalog_mock_data_source.dart';
import 'package:deux_lapins/domain/models/product.dart';
import 'package:deux_lapins/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._dataSource);
  final CatalogMockDataSource _dataSource;

  Future<dynamic> _get(String path) async {
    final response = await _dataSource.request('GET', path);
    if (response['success'] != true) {
      final error = response['error'] as Map<String, dynamic>?;
      if (error?['code'] == 'NOT_FOUND') return null;
      throw StateError(error?['message']?.toString() ?? '상품 조회 실패');
    }
    return response['data'];
  }

  @override
  Future<List<Product>> getProducts() async {
    final data = await _get('/products') as List<dynamic>;
    return data
        .map((row) => ProductModel.fromJson(row as Map<String, dynamic>).toEntity())
        .toList(growable: false);
  }

  @override
  Future<Product?> getProduct(String productId) async {
    final data = await _get('/products/${Uri.encodeComponent(productId)}');
    if (data == null) return null;
    return ProductModel.fromJson(data as Map<String, dynamic>).toEntity();
  }
}
