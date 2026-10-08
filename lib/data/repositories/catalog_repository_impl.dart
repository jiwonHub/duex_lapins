import 'package:duex_lapins/data/services/catalog_mock_data_source.dart';
import 'package:duex_lapins/domain/models/product.dart';
import 'package:duex_lapins/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._dataSource);
  final CatalogMockDataSource _dataSource;

  @override
  Future<List<Product>> getProducts() async {
    final models = await _dataSource.getProducts();
    return models.map((e) => e.toEntity()).toList(growable: false);
  }
}
